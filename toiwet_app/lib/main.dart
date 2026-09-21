import 'package:flutter/material.dart';
import 'theme.dart';

import 'farmer_page.dart';
import 'sheep_page.dart';
import 'vet_page.dart';
import 'login_page.dart';

void main() {
  runApp(const ToiwetApp());
}

class ToiwetApp extends StatelessWidget {
  const ToiwetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toiwet Farmers Group',
      debugShowCheckedModeBanner: false,
      theme: toiwetTheme,
      // Sets the Shepherd Login Page as the starting screen
      home: LoginPage(), 
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FarmerPage(),
    SheepPage(),
    VetPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Farmers'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Sheep'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Vet'),
        ],
      ),
    );
  }
}