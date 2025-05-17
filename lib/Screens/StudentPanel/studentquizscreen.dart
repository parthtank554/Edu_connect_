import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/StudentPanel/Certificate_Screen.dart';
// import 'package:flutterpro/Screens/StudentPanel/Certificate_Screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final String courseId;
  final String quizId;

  const StudentQuizScreen({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  @override
  _StudentQuizScreenState createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  late Future<Map<String, dynamic>> quizData;
  Map<int, String?> userAnswers = {}; // Track user's answers for each question
  String? userId;

  @override
  void initState() {
    super.initState();
    // Fetch user ID
    _fetchUserId();
    // Fetch quiz data using both courseId and quizId
    quizData = fetchQuizData(widget.courseId, widget.quizId);
  }

  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Store the user ID
      });
    }
  }

  Future<Map<String, dynamic>> fetchQuizData(
      String courseId, String quizId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return {
          'title': data['title'] ?? 'Untitled Quiz',
          'description': data['description'] ?? 'No description available',
          'questions': data['questions'] ?? [],
        };
      } else {
        throw 'Quiz not found';
      }
    } catch (e) {
      throw 'Error fetching quiz data: $e';
    }
  }

  void submitQuiz() async {
    // Wait for quizData to be resolved before proceeding
    final quiz =
        await quizData; // Now quizData is resolved to Map<String, dynamic>
    final questions = List<Map<String, dynamic>>.from(quiz['questions'] ?? []);
    int score = 0;

    // Calculate score based on user's answers
    for (int i = 0; i < questions.length; i++) {
      final correctAnswer =
          questions[i]['correctAnswerIndex']; // Correct answer from Firestore
      final selectedAnswer = userAnswers[i];
      final options = List<String>.from(questions[i]['options']);
      final selectedIndex =
          options.indexOf(selectedAnswer!); // User's selected answer

      print(
          'Question $i: Correct Answer: $correctAnswer, Selected Answer: $selectedAnswer');

      // Compare selected answer with the correct answer
      if (correctAnswer == selectedIndex) {
        score++;
      }
    }

    // Store score in Firestore under the user's quiz attempt, using the userId
    if (userId != null) {
      FirebaseFirestore.instance.collection('userScores').add({
        'userId': userId, // Use the fetched user ID
        'quizId': widget.quizId,
        'courseId': widget.courseId,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        // Show score and handle UI after submission
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Completed'),
            content: Text('Your score is: $score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the first dialog
                  _showGenerateCertificateDialog(); // Show second dialog for certificate generation
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }).catchError((e) {
        // Handle error if storing score fails
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Failed to submit your score. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

// Method to show dialog for certificate generation
  void _showGenerateCertificateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Generate Certificate'),
        content: const Text(
            'Do you want to generate your certificate for this quiz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the certificate dialog
              _generateCertificate(); // Call the function to generate certificate
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Close the certificate dialog without generating
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

// Method to generate the certificate (you can customize this as per your logic)
  void _generateCertificate() {
    // Add logic to generate the certificate here
    // For now, just showing a simple message
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Certificate Generated'),
        content:
            const Text('Your certificate has been generated successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CertificatePage(courseId: widget.courseId),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quiz",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: quizData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No quiz data available.'));
          }

          // Extract quiz data
          final quiz = snapshot.data!;
          final title = quiz['title'];
          final questions =
              List<Map<String, dynamic>>.from(quiz['questions'] ?? []);

          // Process questions to include correctAnswer
          final processedQuestions = questions.map((question) {
            final options = List<String>.from(question['options'] ?? []);
            final correctAnswerIndex = question['correctAnswerIndex'] ?? 0;

            return {
              'questionText':
                  question['questionText'] ?? 'No question provided',
              'options': options,
              'correctAnswer':
                  options.isNotEmpty ? options[correctAnswerIndex] : '',
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: processedQuestions.length,
                    itemBuilder: (context, index) {
                      final question = processedQuestions[index];
                      return QuizQuestionWidget(
                        questionText: question['questionText'],
                        options: question['options'],
                        correctAnswer: question['correctAnswer'],
                        onAnswerSelected: (answer) {
                          setState(() {
                            userAnswers[index] = answer;
                          });
                        },
                      );
                    },
                  ),
                ),
                if (userAnswers.length == processedQuestions.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: submitQuiz,
                      child: const Text('Submit Quiz'),
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

class QuizQuestionWidget extends StatefulWidget {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final Function(String) onAnswerSelected;

  const QuizQuestionWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
  });

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  String? selectedAnswer;
  bool isAnswered = false;
  List<String?> answer = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.options.map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: selectedAnswer,
                title: Text(option),
                onChanged: isAnswered
                    ? null
                    : (value) {
                        setState(() {
                          selectedAnswer = value;
                          isAnswered = true;
                          answer.add(selectedAnswer);
                        });
                        widget.onAnswerSelected(
                            value!); // Pass the selected answer back
                      },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
