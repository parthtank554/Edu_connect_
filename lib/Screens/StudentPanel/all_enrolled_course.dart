import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/StudentPanel/enrolled_course_screen.dart';

class AllEnrolledCourse extends StatefulWidget {
  const AllEnrolledCourse({super.key});

  @override
  State<AllEnrolledCourse> createState() => _AllEnrolledCourseState();
}

class _AllEnrolledCourseState extends State<AllEnrolledCourse>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _enrolledCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchEnrolledCourses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchEnrolledCourses();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get(GetOptions(source: Source.server));

        if (userDoc.exists) {
          List<String> enrolledCourseIds =
              List<String>.from(userDoc['enrolledCourses'] ?? []);

          if (enrolledCourseIds.isNotEmpty) {
            List<Map<String, dynamic>> courses = [];
            for (String courseId in enrolledCourseIds) {
              DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .get();

              if (courseDoc.exists) {
                courses.add({
                  'id': courseId,
                  'title': courseDoc['title'],
                  'description': courseDoc['description'],
                  'image': courseDoc['image'],
                  'pdf': courseDoc['pdf'],
                  'videoUrl': courseDoc['videoUrl'],
                });
              }
            }
            setState(() {
              _enrolledCourses.clear();
              _enrolledCourses = courses;
              _isLoadingCourses = false;
            });
          } else {
            setState(() {
              _enrolledCourses = [];
              _isLoadingCourses = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching enrolled courses: $e");
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text("Enrolled Course"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoadingCourses
                  ? const Center(child: CircularProgressIndicator())
                  : _enrolledCourses.isEmpty
                      ? const Center(
                          child: Text(
                            'No enrolled courses yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _enrolledCourses.length,
                          itemBuilder: (context, index) {
                            final course = _enrolledCourses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              elevation: 4,
                              child: ListTile(
                                leading: course['image'] != null &&
                                        course['image'].isNotEmpty
                                    ? Image.network(
                                        course['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.book, size: 50),
                                title: Text(course['title']),
                                subtitle: Text(course['description']),
                                onTap: () async {
                                  final bool? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EnrolledCourseScreen(
                                          course: course,
                                        ),
                                      ));
                                  if (result != null) {
                                    if (!result) {
                                      await _fetchEnrolledCourses();
                                      setState(() {});
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
