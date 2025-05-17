import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/InstructorDashBoard_Screen.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CourseManage/CreateCourse_Screen.dart';

class mainPanel extends StatefulWidget {
  const mainPanel({super.key});

  @override
  State<mainPanel> createState() => _mainPanelState();
}

class _mainPanelState extends State<mainPanel> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    InstructorDashboardScreen(),
    CreateCourseScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Panel'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'DashBoard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Course',
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
