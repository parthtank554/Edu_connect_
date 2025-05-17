import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CertificatePage extends StatefulWidget {
  final String courseId;

  const CertificatePage({Key? key, required this.courseId}) : super(key: key);

  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  String userName = "";
  String courseName = "";
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchDetails(); // Fetch both user and course details together
  }

  // Fetch both user and course details
  Future<void> _fetchDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in');
        setState(() {
          isLoading = false;
        });
        return; // If the user is not logged in, stop fetching
      }

      // Run both fetch calls concurrently using Future.wait
      await Future.wait([
        _fetchUserDetails(user.uid), // Fetch user details
        _fetchCourseDetails(), // Fetch course details
      ]);
    } catch (e) {
      print(
          'Error fetching details: $e'); // Print error if something goes wrong
    } finally {
      setState(() {
        isLoading = false; // Set loading to false once data is fetched
      });
    }
  }

  // Fetch user details (name)
  Future<void> _fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot['fullName'] ?? "User"; // Set the fetched name
        });
      } else {
        print('User data not found');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  // Fetch course details (name)
  Future<void> _fetchCourseDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();
      if (snapshot.exists) {
        setState(() {
          courseName =
              snapshot['title'] ?? "Course Name"; // Set the fetched course name
        });
      } else {
        print('Course data not found');
      }
    } catch (e) {
      print('Error fetching course details: $e');
    }
  }

  // Function to generate the PDF certificate
  Future<void> _generateCertificate() async {
    final pdf = pw.Document();

    // Add certificate content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Certificate of Completion',
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 24),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'has successfully completed the course',
                  style: const pw.TextStyle(fontSize: 24),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  courseName,
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 50),
                pw.Text(
                  'Date: ${DateTime.now().toLocal()}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Trigger the PDF download
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Certificate'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading until data is fetched
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userName.isNotEmpty && courseName.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name: $userName',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Course Name: $courseName',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generateCertificate,
                          child: const Text('Generate Certificate'),
                        ),
                      ],
                    ),
                  if (userName.isEmpty && courseName.isEmpty)
                    const Center(
                        child: Text('Failed to load user/course details')),
                ],
              ),
      ),
    );
  }
}
