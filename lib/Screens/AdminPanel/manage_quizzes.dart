import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({super.key});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> quizzes = [];

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  @override
  void dispose() {
    // Clean up any resources here if needed
    super.dispose();
  }

  Future<void> _fetchQuizzes() async {
    try {
      // First get all courses
      QuerySnapshot coursesSnapshot =
          await _firestore.collection('courses').get();
      List<Map<String, dynamic>> fetchedQuizzes = [];

      // For each course, get its quizzes
      for (var courseDoc in coursesSnapshot.docs) {
        QuerySnapshot quizzesSnapshot = await _firestore
            .collection('courses')
            .doc(courseDoc.id)
            .collection('quizzes')
            .get();

        Map<String, dynamic> courseData =
            courseDoc.data() as Map<String, dynamic>;

        // Add each quiz with its course details
        for (var quizDoc in quizzesSnapshot.docs) {
          Map<String, dynamic> quizData =
              quizDoc.data() as Map<String, dynamic>;

          fetchedQuizzes.add({
            'id': quizDoc.id,
            'courseId': courseDoc.id,
            'title': quizData['title'] ?? 'Untitled Quiz',
            'description': quizData['description'] ?? 'No Description',
            'courseName': courseData['title'] ?? 'Unknown Course',
            'totalQuestions': quizData['questions']?.length ?? 0,
            'duration': quizData['duration'] ?? 0,
            'createdAt': quizData['createdAt'],
          });
        }
      }

      if (mounted) {
        setState(() {
          quizzes = fetchedQuizzes;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching quizzes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuiz(String quizId, String courseId) async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Quiz'),
              content: const Text(
                  'Are you sure you want to delete this quiz? This action cannot be undone.'),
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

      if (!confirmDelete) return;

      // Delete quiz from Firestore
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .delete();

      // Refresh the list
      if (mounted) {
        _fetchQuizzes();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quizzes'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No quizzes found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.quiz, color: Colors.white),
                        ),
                        title: Text(
                          quiz['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course: ${quiz['courseName']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Questions: ${quiz['totalQuestions']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteQuiz(quiz['id'], quiz['courseId']),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quiz['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Duration:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${quiz['duration']} minutes',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Created At:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(quiz['createdAt']),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
