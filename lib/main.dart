import 'dart:async';

import 'package:blog/action_screens/add_blog.dart';
import 'package:blog/ui_components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'screens/home.dart';
import 'splash_screen.dart';
import 'screens/profile.dart';
import 'screens/search.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Onest',
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, brightness: Brightness.dark),
      ),
      home: const SplashScreen(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentPageIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddBlog())),
        child: const Icon(Icons.edit),
      ),
      appBar: blogAppBar(),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (value) => setState(() {
                _currentPageIndex = value;
              }),
          selectedIndex: _currentPageIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_filled),
              label: 'Блоги',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Поиск',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Профиль',
            )
          ]),
    );
  }
}
