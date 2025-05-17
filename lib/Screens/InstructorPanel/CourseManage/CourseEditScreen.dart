import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateEditCourseScreen extends StatefulWidget {
  final Map<String, dynamic>? course;

  const CreateEditCourseScreen({Key? key, this.course}) : super(key: key);

  @override
  _CreateEditCourseScreenState createState() => _CreateEditCourseScreenState();
}

class _CreateEditCourseScreenState extends State<CreateEditCourseScreen> {
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  bool _isCoursePublished = false;
  String _courseFormat = 'Video';
  String? _selectedCategory;
  String? _imageUrl;
  File? _imageFile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _categories = ['Design', 'Technology', 'Business', 'Art'];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _courseTitleController.text = widget.course!['title'] ?? '';
      _courseDescriptionController.text = widget.course!['description'] ?? '';
      _coursePriceController.text = widget.course!['price'] ?? '';
      _selectedCategory = widget.course!['category'] ?? _categories.first;
      _courseFormat = widget.course!['format'] ?? 'Video';
      _isCoursePublished = widget.course!['isPublished'] ?? false;
      _imageUrl = widget.course!['imageUrl'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance.ref().child('course_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Image upload failed: $e');
      return null;
    }
  }

  Future<void> saveCourse() async {
    User? user = _auth.currentUser;

    if (user == null) {
      _showSnackBar('No user logged in. Please log in first.');
      return;
    }

    String title = _courseTitleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Course title is required.');
      return;
    }

    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    Map<String, dynamic> courseData = {
      'title': title,
      'description': _courseDescriptionController.text.trim(),
      'price': _coursePriceController.text.trim(),
      'category': _selectedCategory ?? 'Uncategorized',
      'format': _courseFormat,
      'isPublished': _isCoursePublished,
      'instructorId': user.uid,
      'updatedAt': Timestamp.now(),
      'imageUrl': imageUrl,
    };

    try {
      QuerySnapshot query = await _firestore.collection('courses').where('title', isEqualTo: title).get();

      if (query.docs.isNotEmpty) {
        String courseId = query.docs.first.id;
        await _firestore.collection('courses').doc(courseId).update(courseData);
        _showSnackBar('Course updated successfully!');
        Navigator.pop(context);
      } else {
        _showSnackBar('Course not found in Firestore with the given title.');
      }
    } catch (e) {
      _showSnackBar('Error updating course: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course != null ? 'Edit Course' : 'Create Course'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Course Title Field
            TextField(
              controller: _courseTitleController,
              decoration: InputDecoration(labelText: 'Course Title'),
              enabled: widget.course == null, // Disable if editing an existing course
            ),
            SizedBox(height: 16),

            // Course Description Field
            TextField(
              controller: _courseDescriptionController,
              decoration: InputDecoration(labelText: 'Course Description'),
              maxLines: null,
            ),
            SizedBox(height: 16),

            // Course Price Field
            TextField(
              controller: _coursePriceController,
              decoration: InputDecoration(labelText: 'Course Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              decoration: InputDecoration(labelText: 'Course Category'),
            ),
            SizedBox(height: 20),

            // Format Dropdown
            DropdownButtonFormField<String>(
              value: _courseFormat,
              items: ['Video', 'Live Session', 'Text-based'].map((format) => DropdownMenuItem(value: format, child: Text(format))).toList(),
              onChanged: (value) => setState(() => _courseFormat = value!),
              decoration: InputDecoration(labelText: 'Course Format'),
            ),
            SizedBox(height: 20),

            // Image Picker
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Course Image'),
            ),
            if (_imageFile != null) Image.file(_imageFile!, height: 150),
            if (_imageUrl != null && _imageFile == null) Image.network(_imageUrl!, height: 150),

            SizedBox(height: 20),

            // Publish Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isCoursePublished,
                  onChanged: (value) => setState(() => _isCoursePublished = value!),
                ),
                Text('Publish Course'),
              ],
            ),
            SizedBox(height: 20),

            // Save or Update Button
            ElevatedButton(
              onPressed: saveCourse,
              child: Text(widget.course != null ? 'Update Course' : 'Save Course'),
            ),
          ],
        ),
      ),
    );
  }
}
