import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Profile_Screen.dart';

class Mainhomescreen extends StatefulWidget {
  const Mainhomescreen({super.key});

  @override
  State<Mainhomescreen> createState() => _MainhomescreenState();
}

class _MainhomescreenState extends State<Mainhomescreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
     HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent, // Color for the selected item
        unselectedItemColor: Colors.black54, // Color for the unselected items
      ),
    );
  }
}
