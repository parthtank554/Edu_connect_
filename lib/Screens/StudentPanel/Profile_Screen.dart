import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/StudentPanel/all_enrolled_course.dart';
import 'package:flutterpro/Screens/StudentPanel/enrolled_course_screen.dart';
import 'package:flutterpro/Screens/authentication/EditProfile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PrivacyPolicy_Screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  String? _profileImageUrl;
  File? _profileImageFile;
  // List<Map<String, dynamic>> _enrolledCourses = [];
  // bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserData();
    // _fetchEnrolledCourses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUserData();
      // _fetchEnrolledCourses();
    }
  }

  // Fetch current user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _profileImageUrl = userDoc['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Handle logout
  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoggingOut = true);

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      } finally {
        setState(() => _isLoggingOut = false);
      }
    } else {
      setState(() => _isLoggingOut = false);
    }
  }

  // Handle delete account
  Future<void> _handleDeleteAccount(BuildContext context) async {
    setState(() => _isDeletingAccount = true);

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action is permanent."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Delete user from Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .delete();

          // Delete the profile image from Firebase Storage (optional)
          if (_profileImageUrl != null) {
            Reference ref =
                FirebaseStorage.instance.refFromURL(_profileImageUrl!);
            await ref.delete();
          }

          // Delete the user from Firebase Authentication
          await currentUser.delete();

          // Clear shared preferences and navigate to the login screen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      } finally {
        setState(() => _isDeletingAccount = false);
      }
    } else {
      setState(() => _isDeletingAccount = false);
    }
  }

  // Future<void> _fetchEnrolledCourses() async {
  //   try {
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(currentUser.uid)
  //           .get();

  //       if (userDoc.exists) {
  //         List<String> enrolledCourseIds =
  //             List<String>.from(userDoc['enrolledCourses'] ?? []);

  //         if (enrolledCourseIds.isNotEmpty) {
  //           List<Map<String, dynamic>> courses = [];
  //           for (String courseId in enrolledCourseIds) {
  //             DocumentSnapshot courseDoc = await FirebaseFirestore.instance
  //                 .collection('courses')
  //                 .doc(courseId)
  //                 .get();

  //             if (courseDoc.exists) {
  //               courses.add({
  //                 'id': courseId,
  //                 'title': courseDoc['title'],
  //                 'description': courseDoc['description'],
  //                 'image': courseDoc['image'],
  //               });
  //             }
  //           }
  //           setState(() {
  //             _enrolledCourses = courses;
  //             _isLoadingCourses = false;
  //           });
  //         } else {
  //           setState(() {
  //             _enrolledCourses = [];
  //             _isLoadingCourses = false;
  //           });
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Error fetching enrolled courses: $e");
  //     setState(() {
  //       _isLoadingCourses = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage("assets/avatar.png")
                                as ImageProvider,
                      ),
                      CircleAvatar(
                        radius: 24, // Adjust the radius as needed
                        backgroundColor:
                            Colors.blueAccent, // Background color of the circle
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            // Navigate to the EditProfileScreen when camera is clicked
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Enrolled Courses Section
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Text(
                //     'Enrolled Courses',
                //     style: TextStyle(
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.blue.shade900,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),
                _buildListTile(Icons.book_rounded, "Enrolled Course", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllEnrolledCourse(),
                      ));
                }),
                _buildListTile(
                  Icons.privacy_tip,
                  'Privacy Policy',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                _buildListTile(
                    Icons.list_outlined, 'Terms & Conditions', () {}),
                _buildListTile(
                    Icons.logout, 'Logout', () => _handleLogout(context)),
                _buildListTile(Icons.delete, 'Delete Account',
                    () => _handleDeleteAccount(context)),
              ],
            ),
          ),
          if (_isLoggingOut || _isDeletingAccount)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0), // Add margin for spacing between cards
      elevation: 4, // Add shadow to give the card a floating effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the tile
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blueAccent, // Icon color
          size: 28, // Adjust icon size for better visibility
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16, // Larger text for readability
            fontWeight: FontWeight.bold, // Bold for emphasis
          ),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios, // A forward arrow icon indicating navigation
          color: Colors.grey, // Subtle color for the trailing icon
          size: 20, // Adjust size of the arrow icon
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 16.0), // Padding inside the ListTile
      ),
    );
  }
}
