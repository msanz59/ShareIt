import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_it/app_settings.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeMode _getTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.theme,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'Share IT',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: _getTheme(currentTheme),
          home: const MainLayout(),
        );
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  final List<Widget> _pages = const [RecievePage(), SendPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (int index) {
                  setState(() {
                    _index = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.download_rounded),
                    label: Text('Recieve'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.send_rounded),
                    label: Text('Send'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_rounded),
                    label: Text('Options'),
                  ),
                ],
              ),
            if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _pages[_index]),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null // If desktop it takes null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (int index) {
                setState(() {
                  _index = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.download_rounded),
                  label: 'Recieve',
                ),
                NavigationDestination(
                  icon: Icon(Icons.send_rounded),
                  label: 'Send',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Options',
                ),
              ],
            ),
    );
  }
}

class RecievePage extends StatefulWidget {
  const RecievePage({super.key});

  @override
  State<RecievePage> createState() => _RecievePageState();
}

class _RecievePageState extends State<RecievePage> {
  bool _isPulsing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isPulsing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userIP = AppSettings.deviceIP.value;
    final String userID = AppSettings.deviceName.value;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: Center(
              child: AnimatedScale(
                scale: _isPulsing ? 1.08 : 0.94,
                duration: const Duration(milliseconds: 5000),
                curve: Curves.easeInOut,
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      _isPulsing = !_isPulsing;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: _isPulsing ? 0.35 : 0.08,
                        ),
                        blurRadius: _isPulsing ? 28 : 10,
                        spreadRadius: _isPulsing ? 6 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            userID,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_rounded, size: 18),
                const SizedBox(width: 8),
                Text(userIP, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Ready to recieve...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final List<File> _selectedFiles = [];

  Future<void> _pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (var file in result.files) {
          if (file.path != null) {
            _selectedFiles.add(File(file.path!));
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.files.length} file(s) selected')),
      );
    }
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      debugPrint('Carpeta seleccionada: ${dir.path}');
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text != null && text.trim().isNotEmpty) {
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/pasted_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(text);
      setState(() {
        _selectedFiles.add(file);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pasted text as file: ${file.path.split(Platform.pathSeparator).last}',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty or has no text')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  onTap: () => _pickFiles(type: FileType.any),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.folder_rounded,
                  label: 'Folder',
                  onTap: _pickFolder,
                ),
                _buildActionCard(
                  context,
                  icon: Icons.text_snippet_rounded,
                  label: 'Text',
                  onTap: () => _pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['txt', 'pdf', 'md', 'doc', 'docx'],
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.image_rounded,
                  label: 'Image',
                  onTap: () => _pickFiles(type: FileType.image),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.paste_rounded,
                  label: 'Paste',
                  onTap: _pasteFromClipboard,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Close devices',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceCard(
                    context,
                    name: 'A',
                    ip: '1.1.1.1',
                    icon: Icons.laptop_mac_rounded,
                  ),
                  _buildDeviceCard(
                    context,
                    name: 'B',
                    ip: '2.2.2.2',
                    icon: Icons.laptop_chromebook_rounded,
                  ),
                  _buildDeviceCard(
                    context,
                    name: 'C',
                    ip: '3.3.3.3',
                    icon: Icons.smartphone_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context, {
    required String name,
    required String ip,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(ip),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Device Name'),
            subtitle: Text(AppSettings.deviceName.value),
            onTap: () {
              _showEditDialog(
                context: context,
                title: 'Change name',
                initialValue: AppSettings.deviceName.value,
                keyboardType: TextInputType.text,
                onSave: (newValue) {
                  if (newValue != '') {
                    setState(() {
                      AppSettings.deviceName.value = newValue;
                    });
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_rounded),
            title: const Text('Save Path'),
            subtitle: Text(AppSettings.savePath.value),
            onTap: () {
              if (AppSettings.savePath.value != 'Downloads (Browser)') {
                _showEditDialog(
                  context: context,
                  title: 'Change path',
                  initialValue: AppSettings.savePath.value,

                  keyboardType: TextInputType.text,
                  onSave: (newValue) {
                    if (newValue != '') {
                      setState(() {
                        AppSettings.savePath.value = newValue;
                      });
                    }
                  },
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_rounded),
            title: const Text('Theme'),
            subtitle: Text(AppSettings.theme.value),
            onTap: () {
              _showOptionsDialog(
                context: context,
                title: 'Select Theme',
                options: ['System', 'Light', 'Dark'],
                selectedOption: AppSettings.theme.value,
                onSelect: (selectedTheme) {
                  setState(() {
                    AppSettings.theme.value = selectedTheme;
                    if (selectedTheme == 'Light') {}
                  });
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Network'),
          ListTile(
            leading: const Icon(Icons.router_rounded),
            title: const Text('Port'),
            subtitle: Text(AppSettings.port.value.toString()),
            onTap: () {
              _showEditDialog(
                context: context,
                title: 'Change Port',
                initialValue: AppSettings.port.value.toString(),
                keyboardType: TextInputType.number,
                onSave: (newValue) {
                  final newPort = int.tryParse(newValue);
                  if (newPort != null) {
                    setState(() {
                      AppSettings.port.value = newPort;
                    });
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Encript'),
            trailing: Switch(
              value: AppSettings.isEncripted.value,
              onChanged: (bool val) {
                setState(() {
                  AppSettings.isEncripted.value = val;
                });
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showOptionsDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelect,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: options.map((option) {
            final isSelected = option == selectedOption;
            return SimpleDialogOption(
              onPressed: () {
                onSelect(option);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
