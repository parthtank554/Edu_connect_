import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_students.dart';
import 'manage_instructors.dart';
import 'manage_courses.dart';
import 'manage_quizzes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/Login_Screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalStudents = 0;
  int totalInstructors = 0;
  int totalCourses = 0;
  int totalQuizzes = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      final futures = await Future.wait([
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .get(),
        FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Instructor')
            .get(),
        FirebaseFirestore.instance.collection('courses').get(),
      ]);

      final studentsSnapshot = futures[0] as QuerySnapshot;
      final instructorsSnapshot = futures[1] as QuerySnapshot;
      final coursesSnapshot = futures[2] as QuerySnapshot;

      final quizCount = await _getTotalQuizCount(coursesSnapshot.docs);

      if (mounted) {
        setState(() {
          totalStudents = studentsSnapshot.docs.length;
          totalInstructors = instructorsSnapshot.docs.length;
          totalCourses = coursesSnapshot.docs.length;
          totalQuizzes = quizCount;
        });
      }
    } catch (e) {
      print('Error fetching counts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int> _getTotalQuizCount(List<QueryDocumentSnapshot> courseDocs) async {
    try {
      final quizzesSnapshot =
          await FirebaseFirestore.instance.collectionGroup('quizzes').get();
      return quizzesSnapshot.docs.length;
    } catch (e) {
      print('Error getting quiz count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error during logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCounts,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard('Total Students', totalStudents, Icons.people),
                  _buildStatCard(
                      'Total Instructors', totalInstructors, Icons.person),
                  _buildStatCard('Total Courses', totalCourses, Icons.book),
                  _buildStatCard('Total Quizzes', totalQuizzes, Icons.quiz),
                ],
              ),
              const SizedBox(height: 32),

              // Management Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Management Options',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Management Options List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    _buildManagementOption(
                      'Manage Students',
                      Icons.people,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageStudentsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementOption(
                      'Manage Instructors',
                      Icons.person,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ManageInstructorsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementOption(
                      'Manage Courses',
                      Icons.book,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCoursesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildManagementOption(
                      'Manage Quizzes',
                      Icons.quiz,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageQuizzesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: Colors.blue.shade800),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementOption(
      String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue.shade800, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.blue.shade800,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
