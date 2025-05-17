import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/view_pdf_screen.dart';
import 'package:flutterpro/Screens/StudentPanel/studentquizscreen.dart';

class EnrolledCourseScreen extends StatefulWidget {
  final dynamic course;
  const EnrolledCourseScreen({super.key, this.course});

  @override
  State<EnrolledCourseScreen> createState() => _EnrolledCourseScreenState();
}

class _EnrolledCourseScreenState extends State<EnrolledCourseScreen> {
  bool isEnrolled = true;
  String? cId;
  dynamic uId;
  bool isCertified = false;

  Future<void> getcourseId(dynamic cr) async {
    print("jnvnncv ${cr['id']}");
    cId = cr['id'];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcourseId(widget.course);
  }

  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      // User? currentUser = FirebaseAuth.instance.currentUser;
      // if (currentUser != null) {
      //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
      //       .collection('quizzes')
      //       .doc(currentUser.uid)
      //       .get();
      //   setState(() {
      //     // cId = userDoc.id;
      //   });
      // }
      // await getcourseId(widget.course);
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('quizzes')
      //     .doc(widget.course['id']) //efdf
      //     .collection('quizzes')
      //     .get();
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course['id'])
          .collection('quizzes')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        print(data);
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

  Future<void> enrollCourse(BuildContext context) async {
    if (!isEnrolled) return;

    bool confirmEnrollment = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Enrollment"),
              content: Text(
                  "Do you want to expel from the course '${widget.course['title']}'?"),
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
    String userID = FirebaseAuth.instance.currentUser!.uid;

    if (confirmEnrollment) {
      try {
        // Update user's enrolled courses
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({
          'enrolledCourses': FieldValue.arrayRemove([cId]), //efdf
        });

        // Update course's enrolled users
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(cId) //efdf
            .update({
          'enrolledUsers': FieldValue.arrayRemove([userID]), //efdf
        });

        setState(() {
          isEnrolled = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expeld successfully!')),
          );
          Navigator.pop(context, isEnrolled);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.course['title'],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.course['image'],
                  height: 220.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Course Title and Info
              Text(
                widget.course['title'],
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                widget.course['description'],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 10),
              widget.course['pdf'] != null
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewPdfScreen(
                                    networkPdfUrl: widget.course['pdf'],
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
              widget.course['videoUrl'] != null
                  ? SelectableText(widget.course['videoUrl'])
                  : SizedBox.shrink(),
              // const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      enrollCourse(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Expel Course")),
              ),
              const SizedBox(height: 24),
              // widget.course['pdf'] != null
              //     ? ElevatedButton(
              //         onPressed: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => ViewPdfScreen(
              //                   networkPdfUrl: widget.course['pdf'],
              //                 ),
              //               ));
              //         },
              //         child: Text("View Pdf"))
              // : SizedBox.shrink(),
              const Text(
                'Quizzes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchQuizzes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('Error loading quizzes: ${snapshot.error}'));
                  }

                  final quizzes = snapshot.data ?? [];
                  if (quizzes.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
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
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentQuizScreen(
                                      courseId: widget.course['id'],
                                      quizId: quiz['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Text(
                    'No quizzes available for this course.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: isCertified
                        ? () {
                            var correctedAnswer = 3;
                            var total = 5;
                            double score = (correctedAnswer / total) * 100;
                            print(score.toInt());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Generate Certificate")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
