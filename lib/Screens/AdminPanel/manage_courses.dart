import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> courses = [];

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();

      List<Map<String, dynamic>> fetchedCourses = [];

      for (var doc in snapshot.docs) {
        // Fetch course details
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch instructor details
        DocumentSnapshot instructorDoc = await _firestore
            .collection('users')
            .doc(data['instructorId'])
            .get();

        Map<String, dynamic> instructorData =
            instructorDoc.data() as Map<String, dynamic>;

        fetchedCourses.add({
          'id': doc.id,
          'title': data['title'] ?? 'Untitled',
          'description': data['description'] ?? 'No Description',
          'category': data['category'] ?? 'Uncategorized',
          'instructorName': instructorData['fullName'] ?? 'Unknown Instructor',
          'enrolledStudents': data['enrolledUsers']?.length ?? 0,
          'createdAt': data['createdAt'],
        });
      }

      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching courses: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Course'),
              content: const Text(
                  'Are you sure you want to delete this course? This will remove it for all enrolled students.'),
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

      // Delete course from Firestore
      await _firestore.collection('courses').doc(courseId).delete();

      // Refresh the list
      _fetchCourses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No courses found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
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
                          child: Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text(
                          course['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructor: ${course['instructorName']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Enrolled Students: ${course['enrolledStudents']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCourse(course['id']),
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
                                  course['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course['category'],
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
                                  _formatTimestamp(course['createdAt']),
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
