import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Custom_Widgets/CustomTextField.dart'; // Import CustomTextField
import 'package:flutterpro/Custom_Widgets/GradientButton.dart'; // Import GradientButton
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // For using File

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = false;
  File? _profileImage; // Variable to store the selected image
  String? _profileImageUrl; // URL of the uploaded image in Firebase Storage

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch current user data from Firestore
  void _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _profileImageUrl = data[
              'profileImageUrl']; // Fetch the profile image URL from Firestore
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save profile data to Firestore
  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // If a new image is selected, upload it to Firebase Storage
          if (_profileImage != null) {
            String fileName = '${currentUser.uid}_profile.jpg';
            UploadTask uploadTask = FirebaseStorage.instance
                .ref('profile_images/$fileName')
                .putFile(_profileImage!);

            TaskSnapshot taskSnapshot = await uploadTask;
            _profileImageUrl = await taskSnapshot.ref
                .getDownloadURL(); // Get the URL of the uploaded image
          }

          // Save user data to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'bio': _bioController.text,
            'profileImageUrl': _profileImageUrl, // Save the image URL
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );

          Navigator.pop(context); // Return to previous screen after saving
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Set the picked image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                    as ImageProvider
                                : const AssetImage(
                                    'assets/default_profile.png')),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: 'Full Name',
                      obscureText: false,
                      icon: Icons.person,
                      controller: _fullNameController,
                      keyboardType: TextInputType.text,
                      isRequired: true,
                      labelText: '',
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: 'Email',
                      icon: Icons.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      obscureText: false,
                      isRequired: true,
                      labelText: '', // Prevent editing the email
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: 'Phone',
                      obscureText: false,
                      icon: Icons.phone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      labelText: '',
                      maxLength: 10,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: 'Bio',
                      icon: Icons.info_outline,
                      obscureText: false,
                      controller: _bioController,
                      keyboardType: TextInputType.text,
                      isRequired: true,
                      labelText: '',
                    ),
                    const SizedBox(height: 30),
                    GradientButton(
                      buttonText: 'Save Changes',
                      onPressed: _saveProfile,
                      gradientColors: const [
                        Colors.blueAccent,
                        Colors.lightBlue,
                      ],
                      label: '',
                      child: const Text(""),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
