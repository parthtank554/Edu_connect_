import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Custom_Widgets/GradientButton.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/view_pdf_screen.dart';
import 'package:flutterpro/Screens/StudentPanel/studentquizscreen.dart';
// import 'Quiz_Screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String courseImage;
  final String courseDescription;
  final String userId; // Pass the userId to identify the user
  final String? videoUrl;
  final String? pdfUrl;

  final List<Map<String, String>> lectures;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.courseImage,
    required this.courseDescription,
    required this.userId, // Add userId to constructor
    this.videoUrl,
    this.pdfUrl,
    required this.lectures,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool isEnrolled = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final enrolledCourses =
            List<String>.from(userDoc.data()?['enrolledCourses'] ?? []);
        setState(() {
          isEnrolled = enrolledCourses.contains(widget.courseId);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking enrollment status: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> enrollCourse(BuildContext context) async {
    if (isEnrolled) return;

    bool confirmEnrollment = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Enrollment"),
              content: Text(
                  "Do you want to enroll in the course '${widget.courseTitle}'?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmEnrollment) {
      try {
        // Update user's enrolled courses
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'enrolledCourses': FieldValue.arrayUnion([widget.courseId]),
        });

        // Update course's enrolled users
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .update({
          'enrolledUsers': FieldValue.arrayUnion([widget.userId]),
        });

        setState(() {
          isEnrolled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enrolled successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error enrolling in the course: $e')),
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('quizzes')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled Quiz',
          'duration': data['duration'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseTitle,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchQuizzes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading quizzes: ${snapshot.error}'));
                }

                final quizzes = snapshot.data ?? [];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.courseImage,
                            height: 220.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Course Title and Info
                        Text(
                          widget.courseTitle,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Course Description
                        const Text(
                          'Course Description',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.courseDescription,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        widget.pdfUrl != null
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewPdfScreen(
                                              networkPdfUrl: widget.pdfUrl,
                                            ),
                                          ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text("View PDF")),
                              )
                            : SizedBox.shrink(),
                        widget.videoUrl != null
                            ? SelectableText(widget.videoUrl!)
                            : SizedBox.shrink(),
                        const SizedBox(height: 10),
                        // Text(widget.pdfUrl!),

                        // Enrollment Button
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            child: isEnrolled
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green.shade700),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Enrolled',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GradientButton(
                                    onPressed: () => enrollCourse(context),
                                    buttonText: 'Enroll Now',
                                    gradientColors: const [
                                      Colors.blue,
                                      Colors.blueAccent
                                    ],
                                    label: '',
                                    child: const Text(""),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quizzes Section
                        const Text(
                          'Quizzes',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        quizzes.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: quizzes.length,
                                itemBuilder: (context, index) {
                                  final quiz = quizzes[index];
                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.quiz,
                                          color: Colors.blueAccent),
                                      title: Text(
                                        quiz['title']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Duration: ${quiz['duration']}',
                                        style: TextStyle(
                                            color: Colors.grey.shade600),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.arrow_forward,
                                            color: Colors.blueAccent),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentQuizScreen(
                                                courseId: widget.courseId,
                                                quizId: quiz['id'],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Text(
                                'No quizzes available for this course.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
