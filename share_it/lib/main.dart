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
                    icon: Icon(Icons.send_rounded),
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
