import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share IT',
      theme: ThemeData(
        colorScheme: .fromSeed(
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
      themeMode: ThemeMode.system,
      home: const MainLayout(),
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

  final List<Widget> _pages = const [
    RecievePage(),
    SendPage(),
  ]; //SendPage(), SettingsPage()];

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
    final String userIP = dotenv.env['USER_IP'] ?? '0.0.0.0';
    final String userID = dotenv.env['USER_ID'] ?? 'Sour Apple';

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
                ),
                _buildActionCard(
                  context,
                  icon: Icons.folder_rounded,
                  label: 'Folder',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.text_snippet_rounded,
                  label: 'Text',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.image_rounded,
                  label: 'Image',
                ),
                _buildActionCard(
                  context,
                  icon: Icons.paste_rounded,
                  label: 'Paste',
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
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
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
