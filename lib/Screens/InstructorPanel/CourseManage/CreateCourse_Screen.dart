import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/view_pdf_screen.dart';
import 'package:flutterpro/Screens/StudentPanel/Quiz_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../Custom_Widgets/CustomTextField.dart';
import '../../../Custom_Widgets/GradientButton.dart';
import 'PreviewCourse_Screen.dart';

class CreateCourseScreen extends StatefulWidget {
  // final File uploadResume;
  final dynamic course;
  final bool? isEdit;
  const CreateCourseScreen({
    super.key,
    this.course,
    this.isEdit,
  });
  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController =
      TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  final TextEditingController _courseCategoryController =
      TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();

  bool _isCoursePublished = false;
  String _courseFormat = 'Video';
  String? _selectedCategory;
  File? image;
  String? networkImage;
  String? networkPdf;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _categories = ['Design', 'Technology', 'Business', 'Art'];
  File? pickedPdf;

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit != null) {
      if (widget.isEdit!) {
        fetchCourseData();
      }
    }
  }

  Future pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        image = File(pickedFile.path);
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> fetchCourseData() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('No user is logged in');
        return;
      }
      DocumentSnapshot courseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(widget.course) // <-- Add the course ID here
          .get();

      if (courseSnapshot.exists) {
        var courseData = courseSnapshot.data() as Map<String, dynamic>;
        print('Course Title: ${courseData['title']}');

        setState(() {
          _courseTitleController.text = courseData['title'];
          _courseDescriptionController.text = courseData['description'];
          _coursePriceController.text = courseData['price'];
          _selectedCategory = courseData['category'];

          _courseFormat = courseData['format'];

          networkImage = courseData['image'];
          if (courseData['videoUrl'] != "") {
            videoLinkController.text = courseData['videoUrl'];
          }
          if (courseData['pdf'] != "") {
            networkPdf = courseData['pdf'];
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> editCourse() async {
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

    String? imageUrl;
    String pdfUrl = "";
    if (image == null && networkImage == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')));
      return;
    }

    if (image != null) {
      String imageFileName =
          'courses/${DateTime.now().millisecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref(imageFileName).putFile(image!);
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    if (pickedPdf != null) {
      String pdfFileName =
          'courses/${DateTime.now().millisecondsSinceEpoch}.pdf';
      UploadTask pdfUploadTask = _storage.ref(pdfFileName).putFile(pickedPdf!);
      TaskSnapshot pdfSnapShot = await pdfUploadTask;
      pdfUrl = await pdfSnapShot.ref.getDownloadURL();
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
      'image': image != null ? imageUrl : networkImage!,
      'videoUrl': videoLinkController.text,
      'pdf': pickedPdf != null ? pdfUrl : networkPdf,
    };

    try {
      // QuerySnapshot query = await _firestore
      //     .collection('courses')
      //     .where('title', isEqualTo: title)
      //     .get();

      // if (query.docs.isNotEmpty) {
      // String courseId = query.docs.first.id;
      await _firestore
          .collection('courses')
          .doc(widget.course)
          .update(courseData);
      _showSnackBar('Course updated successfully!');
      Navigator.pop(context);
      // }
      //  else {
      //   _showSnackBar('Course not found in Firestore with the given title.');
      // }
    } catch (e) {
      _showSnackBar('Error updating course: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> saveCourse() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No user logged in. Please log in first.')));
      return;
    }

    String? imageUrl;
    String pdfUrl = "";
    if (image == null && networkImage == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')));
      return;
    }

    try {
      if (image != null) {
        String imageFileName =
            'courses/${DateTime.now().millisecondsSinceEpoch}.png';
        UploadTask uploadTask = _storage.ref(imageFileName).putFile(image!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (pickedPdf != null) {
        String pdfFileName =
            'courses/${DateTime.now().millisecondsSinceEpoch}.pdf';
        UploadTask pdfUploadTask =
            _storage.ref(pdfFileName).putFile(pickedPdf!);
        TaskSnapshot pdfSnapShot = await pdfUploadTask;
        pdfUrl = await pdfSnapShot.ref.getDownloadURL();
      }

      String courseId = _firestore.collection('courses').doc().id;
      Map<String, dynamic> courseData = {
        'title': _courseTitleController.text,
        'description': _courseDescriptionController.text,
        'price': _coursePriceController.text,
        'category': _selectedCategory,
        'format': _courseFormat,
        'isPublished': _isCoursePublished,
        'instructorId': user.uid,
        'createdAt': Timestamp.now(),
        'image': image != null ? imageUrl : networkImage!,
        'videoUrl': videoLinkController.text,
        'pdf': pickedPdf != null ? pdfUrl : networkPdf,
      };

      await _firestore.collection('courses').doc(courseId).set(courseData);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc(courseId)
          .set(courseData);

      Map<String, dynamic> quizData = {
        'courseId': courseId,
        'questions': [],
        'createdAt': Timestamp.now(),
      };
      await _firestore.collection('quizzes').doc(courseId).set(quizData);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course saved successfully!')));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizScreen(
                  courseId: courseId,
                )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving course: $e')));
    }
  }

  /*Future<void> addFieldToAllDocs() async {
    final collection = FirebaseFirestore.instance.collection('courses');

    final querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'videoUrl': videoLinkController.text ?? "",
      });
    }
  }*/ // function for adding fields in firebase collection

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
      ],
    );

    if (pickedFile != null && pickedFile.files.isNotEmpty) {
      setState(() {
        pickedPdf = File(pickedFile.files.single.path!);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pdf uploade')));

      // You can now use the filePath
    } else {
      print('No file selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Create Course',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                  hintText: 'Course Title',
                  icon: Icons.title,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  maxLines: 1,
                  controller: _courseTitleController,
                  isRequired: true,
                  labelText: ''),
              const SizedBox(height: 16),
              CustomTextField(
                  hintText: 'Course Description',
                  icon: Icons.description,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  controller: _courseDescriptionController,
                  maxLines: null,
                  isRequired: true,
                  labelText: ''),
              const SizedBox(height: 16),
              CustomTextField(
                  hintText: 'Course Price',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  maxLines: 1,
                  controller: _coursePriceController,
                  isRequired: true,
                  labelText: ''),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Course Category',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _courseFormat,
                items: ['Video', 'Live Session', 'Text-based']
                    .map((format) =>
                        DropdownMenuItem(value: format, child: Text(format)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _courseFormat = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Course Format',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              _courseFormat.toLowerCase() == "video"
                  ? TextFormField(
                      controller: videoLinkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        label: const Text("Paste video link here"),
                      ),
                    )
                  : _courseFormat.toLowerCase() == "text-based"
                      ? (pickedPdf == null && networkPdf == ""
                          ? GradientButton(
                              onPressed: () {
                                pickPdf();
                              },
                              buttonText: 'Select PDF',
                              gradientColors: [Colors.blue, Colors.blueAccent],
                              label: '',
                              child: const Text(""),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          pickPdf();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: const Text("Edit Pdf")),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // GradientButton(
                                //   onPressed: () {
                                //     // You can add code here to view the picked PDF
                                //     // viewPdf();
                                //   },
                                //   buttonText: 'View PDF',
                                //   gradientColors: [
                                //     Colors.blue,
                                //     Colors.blueAccent
                                //   ],
                                //   label: '',
                                //   child: const Text(""),
                                // ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (pickedPdf != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewPdfScreen.file(
                                                      pickedPdf!),
                                            ),
                                          );
                                        } else if (networkPdf != null &&
                                            networkPdf!.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewPdfScreen.network(
                                                      networkPdf!),
                                            ),
                                          );
                                        } else {
                                          // optional: show message if both are missing
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'No PDF available to view.')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: const Text("View PDF"),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                      : const SizedBox.shrink(),
              const SizedBox(height: 20),
              (networkImage != null)
                  ? Image.network(
                      networkImage!,
                      height: 350,
                      width: 160,
                      fit: BoxFit.fill,
                    )
                  : (image != null)
                      ? Image.file(
                          image!,
                          width: 350,
                          height: 160,
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          Constants.logo,
                          width: 350,
                          height: 160,
                          fit: BoxFit.fill,
                        ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () => _showBottomSheet(context),
                  child: const Text('Pick an Image')),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: widget.isEdit != null
                    ? widget.isEdit!
                        ? () {
                            editCourse();
                          }
                        : () {
                            saveCourse();
                          }
                    : () {
                        saveCourse();
                      },
                buttonText: widget.isEdit != null
                    ? widget.isEdit!
                        ? 'Edit Course'
                        : 'Save Course'
                    : 'Save Course',
                gradientColors: [Colors.blue, Colors.blue, Colors.blueAccent],
                label: '',
                child: const Text(""),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
