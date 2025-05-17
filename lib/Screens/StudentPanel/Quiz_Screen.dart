import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/InstructorDashBoard_Screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/mainPanel.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;
  QuizScreen({required this.courseId, String? quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _quizTitleController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Question> _questions = [
    Question(
        questionText: '', options: List.filled(4, ''), correctAnswerIndex: 0),
  ];

  void _addQuestion() {
    if (_questions.length < 50) {
      setState(() {
        _questions.add(Question(
            questionText: '',
            options: List.filled(4, ''),
            correctAnswerIndex: 0));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 50 questions allowed')),
      );
    }
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one question is required')),
      );
    }
  }

  void _saveQuiz() async {
    if (_quizTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz title')),
      );
      return;
    }

    bool allQuestionsValid = _questions.every((q) =>
        q.questionText.isNotEmpty && q.options.every((o) => o.isNotEmpty));

    if (!allQuestionsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all questions and options')),
      );
      return;
    }

    try {
      // Add quiz to Firestore
      await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('quizzes')
          .add({
        'title': _quizTitleController.text,
        'questions': _questions
            .map((q) => {
                  'questionText': q.questionText,
                  'options': q.options,
                  'correctAnswerIndex': q.correctAnswerIndex,
                })
            .toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz saved successfully')),
      );

      if (mounted) {
        // Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const mainPanel(),
            ));
      } // Go back after saving the quiz
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _quizTitleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return QuestionCard(
                    question: _questions[index],
                    index: index,
                    onDelete: () => _removeQuestion(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                  ),
                ),
                const SizedBox(width: 08),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveQuiz,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Quiz'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Question {
  String questionText;
  List<String> options;
  int correctAnswerIndex;

  Question(
      {required this.questionText,
      required this.options,
      required this.correctAnswerIndex});
}

class QuestionCard extends StatefulWidget {
  final Question question;
  final int index;
  final VoidCallback onDelete;

  QuestionCard(
      {required this.question, required this.index, required this.onDelete});

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final _questionTextController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _selectedOptionIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionTextController.text = widget.question.questionText;
    for (int i = 0; i < 4; i++) {
      _optionControllers[i].text = widget.question.options[i];
    }
    _selectedOptionIndex = widget.question.correctAnswerIndex;
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCorrectAnswer(int index) {
    setState(() {
      _selectedOptionIndex = index;
      widget.question.correctAnswerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionTextController,
                    decoration: InputDecoration(
                      labelText: 'Question ${widget.index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => widget.question.questionText = value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _selectedOptionIndex,
                        activeColor: Colors.blueAccent,
                        onChanged: (value) => _updateCorrectAnswer(i),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${String.fromCharCode(65 + i)}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              widget.question.options[i] = value,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
