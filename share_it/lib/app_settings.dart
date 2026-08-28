import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSettings {
  static final ValueNotifier<bool> isEncripted = ValueNotifier<bool>(false);

  static final ValueNotifier<int> port = ValueNotifier<int>(53398);

  static final ValueNotifier<String> theme = ValueNotifier<String>(
    dotenv.env['THEME'] ?? 'System',
  );

  static final ValueNotifier<String> deviceName = ValueNotifier(
    dotenv.env['USER_ID'] ?? 'unregistred device',
  );

  static final ValueNotifier<String> deviceIP = ValueNotifier(
    dotenv.env['USER_IP'] ?? '0.0.0.0',
  );

  static final ValueNotifier<String> savePath = ValueNotifier<String>(
    _getDefaultSavePath(),
  );

  static String _getDefaultSavePath() {
    if (dotenv.env['SAVE_PATH'] != null &&
        dotenv.env['SAVE_PATH']!.isNotEmpty) {
      return dotenv.env['SAVE_PATH']!;
    }

    if (kIsWeb) {
      return 'Downloads (Browser)';
    }

    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        return '$userProfile\\Downloads';
      } else if (Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '';
        return '$home/Downloads';
      } else if (Platform.isAndroid) {
        return '/storage/emulated/0/Download';
      }
    } catch (_) {}

    return '';
  }
}
