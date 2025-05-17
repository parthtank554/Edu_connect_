import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageInstructorsScreen extends StatefulWidget {
  const ManageInstructorsScreen({super.key});

  @override
  State<ManageInstructorsScreen> createState() =>
      _ManageInstructorsScreenState();
}

class _ManageInstructorsScreenState extends State<ManageInstructorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> instructors = [];

  @override
  void initState() {
    super.initState();
    _fetchInstructors();
  }

  Future<void> _fetchInstructors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Instructor')
          .get();

      List<Map<String, dynamic>> fetchedInstructors = [];

      for (var doc in snapshot.docs) {
        // Fetch instructor's courses
        QuerySnapshot coursesSnapshot = await _firestore
            .collection('users')
            .doc(doc.id)
            .collection('courses')
            .get();

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedInstructors.add({
          'id': doc.id,
          'name': data['fullName'] ?? 'No Name',
          'email': data['email'] ?? 'No Email',
          'courseCount': coursesSnapshot.docs.length,
          'courses': coursesSnapshot.docs
              .map((course) => course['title'] ?? 'Untitled')
              .toList(),
        });
      }

      setState(() {
        instructors = fetchedInstructors;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching instructors: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching instructors: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteInstructor(String instructorId) async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Instructor'),
              content: const Text(
                  'Are you sure you want to delete this instructor? This will also delete all their courses.'),
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

      // Delete instructor's courses first
      QuerySnapshot coursesSnapshot = await _firestore
          .collection('users')
          .doc(instructorId)
          .collection('courses')
          .get();

      for (var course in coursesSnapshot.docs) {
        await course.reference.delete();
      }

      // Delete instructor from Firestore
      await _firestore.collection('users').doc(instructorId).delete();

      // Delete instructor's authentication account
      await _auth.currentUser?.delete();

      // Refresh the list
      _fetchInstructors();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instructor deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting instructor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting instructor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Instructors'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructors.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No instructors found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: instructors.length,
                  itemBuilder: (context, index) {
                    final instructor = instructors[index];
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
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          instructor['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instructor['email'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Courses: ${instructor['courseCount']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteInstructor(instructor['id']),
                        ),
                        children: [
                          if (instructor['courses'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Associated Courses:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...instructor['courses']
                                      .map<Widget>((course) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, bottom: 4.0),
                                            child: Text(
                                              '• $course',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
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
