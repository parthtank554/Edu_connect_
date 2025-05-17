import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/FirebaseServices/AuthenticationManager.dart';
import 'package:flutterpro/Screens/InstructorPanel/mainPanel.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import 'package:flutterpro/main.dart';
import '../InstructorPanel/InstructorDashBoard_Screen.dart';
import '../StudentPanel/mainHomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulated delay

    try {
      var user = _authService.getCurrentUser();

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        String role = userData?['role'] ?? 'Student';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);
        await prefs.setBool('isLoggedIn', true);


          // Navigate based on role
          if (role == 'Instructor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainPanel()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Mainhomescreen()),
            );
          }
        } else {
          // Navigate to Login Screen if not logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      
    } catch (e) {
      // Handle errors and fallback to Login Screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                Constants.logo, // Update with your logo path
                height: 180,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
