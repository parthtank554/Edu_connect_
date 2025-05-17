import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CreateCourse_Screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/ManageCourse.dart';
import 'package:flutterpro/Screens/InstructorPanel/InstructorProfile_screen.dart';
import 'package:flutterpro/Screens/StudentPanel/Profile_Screen.dart';
import 'package:flutterpro/Screens/StudentPanel/Quiz_Screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User's course data
  List<Map<String, dynamic>> _courses = [];
  int _totalStudents = 0;
  int _totalCourses = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInstructorData();
  }

  Future<void> _fetchInstructorData() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('No user is logged in');
        return;
      }

      // Fetch courses for the logged-in instructor
      QuerySnapshot courseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      if (courseSnapshot.docs.isEmpty) {
        print('No courses found');
        return;
      }

      // Fetch all courses and their student count from the enrolledUsers field
      List<Map<String, dynamic>> fetchedCourses = [];
      int totalStudentsCount = 0;

      // Iterate through all course documents
      for (var doc in courseSnapshot.docs) {
        Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
        courseData['id'] = doc.id;

        // Fetch the enrolledUsers field (list of student IDs)
        List<dynamic> enrolledUsers = courseData['enrolledUsers'] ?? [];
        print("Course ID: ${doc.id}, Enrolled Users: $enrolledUsers");

        // Check if enrolledUsers is a list and count the length
        int studentCount = 0;
        if (enrolledUsers is List) {
          studentCount = enrolledUsers.length; // Get the number of students
        } else {
          print("Invalid enrolledUsers format for course ${doc.id}");
        }

        // Update the total students count
        totalStudentsCount += studentCount;

        // Add student count to course data
        courseData['studentCount'] = studentCount;

        // Add course data to the list
        fetchedCourses.add(courseData);
      }

      // Update state with fetched courses and student count
      setState(() {
        _courses = fetchedCourses;
        _totalCourses = _courses.length;
        _totalStudents = totalStudentsCount;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching instructor data: $e");
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No user logged in.')));
      return;
    }

    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc(courseId)
          .delete();

      await _firestore.collection('courses').doc(courseId).delete();

      setState(() {
        _courses.removeWhere((course) => course['id'] == courseId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully!')));
      // setState(() {});
      _fetchInstructorData();
    } catch (e) {
      print('Error deleting course: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting course: $e')));
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: const Text(
                'Are you sure you want to delete this course? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _editCourse(dynamic courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCourseScreen(
          course: courseId,
          isEdit: true,
        ),
      ),
    );
  }

  void _addQuiz(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Instructor Dashboard",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InstructorProfilePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course & Student Summary Section
              _buildSummaryCard('Courses', _totalCourses.toString(),
                  color: Colors.blueGrey),
              const SizedBox(height: 20),
              // Manage Courses Section
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                      ? const Center(child: Text('No courses found.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(4.0),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return CourseCard(
                              course: course,
                              onEdit: () => _editCourse(course['id']),
                              onDelete: () => _deleteCourse(course['id']),
                              onAddQuiz: () => _addQuiz(course['id']),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {Color? color}) {
    final baseColor = color ?? Colors.blueAccent;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              baseColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddQuiz;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
    required this.onAddQuiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: Colors.black.withOpacity(0.3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                course['image'] ?? 'https://via.placeholder.com/150',
                width: double.infinity,
                height: 180,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                right: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Course Category
                  Text(
                    course['category'] ?? 'Uncategorized',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onEdit,
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDelete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Add Quiz Button
                  Center(
                    child: ElevatedButton(
                      onPressed: onAddQuiz,
                      child: const Text(
                        'Add Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
