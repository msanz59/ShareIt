import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class TcpSender {
  Future<void> sendFile({
    required String targetIP,
    required int port,
    required File file,
    Function(double progress)? onProgress,
  }) async {
    final socket = await Socket.connect(targetIP, port);

    try {
      final fileName = file.uri.pathSegments.last;
      final fileSize = await file.length();

      final metadata = jsonEncode({
        'type': 'file',
        'name': fileName,
        'size': fileSize,
      });
      final metadatabytes = utf8.encode(metadata);

      final headerLength = ByteData(4)
        ..setUint32(0, metadatabytes.length, Endian.big);
      // tell how much metadata
      socket.add(headerLength.buffer.asUint8List());
      // send metadata
      socket.add(metadatabytes);
      // send file
      int bytesSent = 0;
      await for (final chunk in file.openRead()) {
        socket.add(chunk);
        bytesSent += chunk.length;
        if (onProgress != null) {
          onProgress(bytesSent / fileSize);
        }
      }

      await socket.flush();
    } finally {
      await socket.close();
    }
  }
}

class TcpReceiver {
  ServerSocket? _server;
  Future<void> startServer({
    required int port,
    required String saveDirectoryPath,
    Function(String fileName, double progress)? onProgress,
  }) async {
    // Hear on local network
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    _server!.listen((Socket clientSocket) {
      _handleClient(clientSocket, saveDirectoryPath, onProgress);
    });
  }

  void _handleClient(
    Socket socket,
    String saveDir,
    Function(String, double)? onProgress,
  ) async {
    final buffer = BytesBuilder(copy: false);
    Map<String, dynamic>? metadata;
    IOSink? fileSink;
    int bytesReceived = 0;
    int totalFileSize = 0;
    String fileName = '';
    await for (final data in socket) {
      buffer.add(data);
      // 1. Read header
      if (metadata == null) {
        if (buffer.length < 4) continue; // wait at least 4B
        final bytes = buffer.takeBytes();
        final headerLen = ByteData.sublistView(
          Uint8List.fromList(bytes.sublist(0, 4)),
        ).getUint32(0, Endian.big);
        if (bytes.length < 4 + headerLen) {
          // add and wait
          buffer.add(bytes);
          continue;
        }
        // 2. Decode JSON
        final jsonBytes = bytes.sublist(4, 4 + headerLen);
        metadata = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
        fileName = metadata['name'];
        totalFileSize = metadata['size'];
        // 3. create destination
        final targetFile = File('$saveDir/$fileName');
        fileSink = targetFile.openWrite();
        // if bytes arived with header, write them
        final remainingPayload = bytes.sublist(4 + headerLen);
        if (remainingPayload.isNotEmpty) {
          fileSink.add(remainingPayload);
          bytesReceived += remainingPayload.length;
        }
      } else {
        // 4. write data
        fileSink?.add(data);
        bytesReceived += data.length;

        if (onProgress != null && totalFileSize > 0) {
          onProgress(fileName, (bytesReceived / totalFileSize).clamp(0.0, 1.0));
        }
      }
    }
    await fileSink?.flush();
    await fileSink?.close();
    await socket.close();
  }

  Future<void> stopServer() async {
    await _server?.close();
  }
}
