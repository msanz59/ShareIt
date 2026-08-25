import 'package:flutter/material.dart';

void main() {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
                NavigationRailDestination(icon: Icon(Icons.send_rounded), label: Text('Send')),
                NavigationRailDestination(icon: Icon(Icons.send_rounded), label: Text('Options'))
              ],
              )
            if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _pages[_index],
            )
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
                  label: 'Recibir',
                ),
                NavigationDestination(
                  icon: Icon(Icons.send_rounded),
                  label: 'Enviar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Ajustes',
                ),
              ],
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
