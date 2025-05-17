import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/authentication/InstructorEditProfile_Screen.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Custom_Widgets/GradientButton.dart';

class InstructorProfilePage extends StatefulWidget {
  @override
  _InstructorProfilePageState createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String fullName = '';
  String email = '';
  String expertise = '';
  String about = '';
  String profileImageUrl =
      'https://via.placeholder.com/150'; // Default image URL

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            fullName = data['fullName'] ?? 'John Doe';
            email = data['email'] ?? 'john@gmail.com';
            expertise = data['expertise'] ?? 'Expert in Technology & Design';
            about = data['about'] ?? 'No bio available.';
            profileImageUrl = data['profileImageUrl'] ??
                'https://via.placeholder.com/150'; // Correct field name
            isLoading = false;
          });
        } else {
          print("User document does not exist!");
          setState(() => isLoading = false);
        }
      } else {
        print("User is not logged in!");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      // Update with your login route
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  // Function to handle account deletion
  Future<void> _deleteAccount() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Delete user from Firestore
        await _firestore.collection('users').doc(uid).delete();

        // Delete user authentication account
        await _auth.currentUser?.delete();

        // Redirect to login screen after deletion
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginScreen())); // Update with your login route
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Instructor Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(profileImageUrl),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expertise,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle,
                                  color: Colors.transparent),
                              SizedBox(width: 5),
                              Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // About Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            about,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientButton(
                        buttonText: 'Edit Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InstructorEditProfileScreen()),
                          ).then((_) {
                            _fetchUserData();
                          });
                        },
                        gradientColors: [Colors.blue, Colors.blueAccent],
                        label: '',
                        child: Text(""),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientButton(
                        onPressed: _logout,
                        gradientColors: [Colors.blue, Colors.blueAccent],
                        label: 'Logout',
                        buttonText: 'Logout',
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientButton(
                        onPressed: _deleteAccount,
                        gradientColors: [
                          Colors.redAccent,
                          Colors.deepOrangeAccent
                        ],
                        label: 'Delete Account',
                        buttonText: 'Delete Account',
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
