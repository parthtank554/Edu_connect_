import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


import '../../Custom_Widgets/CustomTextField.dart';
import '../../Custom_Widgets/GradientButton.dart';
import 'package:image_picker/image_picker.dart';

class InstructorEditProfileScreen extends StatefulWidget {
  @override
  State<InstructorEditProfileScreen> createState() =>
      _InstructorEditProfileScreenState();
}

class _InstructorEditProfileScreenState
    extends State<InstructorEditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController expertiseController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
 String? _profileImageUrl;
  File? _profileImageFile;
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
            nameController.text = data['fullName'] ?? '';
            emailController.text = data['email'] ?? '';
            aboutController.text = data['about'] ?? '';
            expertiseController.text = data['expertise'] ?? '';
                        _profileImageUrl = data['profileImageUrl'];

            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Your Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Picture Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                 CircleAvatar(
        radius: 60,
        backgroundImage: _profileImageUrl != null
            ? NetworkImage(_profileImageUrl!) // Use the profile image URL from Firestore
            : AssetImage('assets/images/default_profile.png') as ImageProvider, // Use a local default image if no URL is available
      ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    onPressed: () async{
await _pickProfileImage();                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Email',
              icon: Icons.email,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              controller: emailController, isRequired: true, labelText: '',
            ),
            const SizedBox(height: 16),

            // Name Text Field
            CustomTextField(
              hintText: 'Full Name',
              icon: Icons.person,
              keyboardType: TextInputType.name,
              obscureText: false,
              controller: nameController,isRequired: true, labelText: '',
            ),

            // Email Text Field

            const SizedBox(height: 16),

            // Expertise Field
            CustomTextField(
              hintText: 'Expertise (e.g., Technology, Design)',
              icon: Icons.school,
              keyboardType: TextInputType.text,
              obscureText: false,
              controller: expertiseController,isRequired: true, labelText: '',
            ),
            const SizedBox(height: 16),

            // About Text Field
            CustomTextField(
              hintText: 'About You',
              icon: Icons.info_outline,
              keyboardType: TextInputType.multiline,
              obscureText: false,
              controller: aboutController,isRequired: true, labelText: '',
              maxLines: 4,
            ),
            const SizedBox(height: 30),

            // Save Button
            GradientButton(
              buttonText: 'Save Changes',
              onPressed: () async {
                // Handle save logic here
                await _updateUserData();
                Navigator.pop(context);
              },
              gradientColors: [Colors.blue, Colors.blueAccent], label: '',child: Text(""), 
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
         String? profileImageUrl = _profileImageUrl;
        if (_profileImageFile != null) {
          profileImageUrl = await _uploadProfileImage(_profileImageFile!);
        }
        await _firestore.collection('users').doc(uid).update({
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'about': aboutController.text.trim(),
          'expertise': expertiseController.text.trim(),
                    'profileImageUrl': profileImageUrl ?? _profileImageUrl,

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print("Error updating user data: $e");
    }
  }
}
