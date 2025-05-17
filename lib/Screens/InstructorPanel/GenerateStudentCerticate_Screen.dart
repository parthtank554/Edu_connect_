import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/ChangeTemplate.dart';

class CertificatesScreen extends StatelessWidget {
  final List<Map<String, String>> eligibleStudents = [
    {'name': 'John Doe', 'course': 'Flutter Basics'},
    {'name': 'Jane Smith', 'course': 'Advanced Flutter'},
    {'name': 'Sam Wilson', 'course': 'UI/UX Design'},
  ];

  final List<Map<String, String>> issuedCertificates = [
    {'name': 'Emily Brown', 'course': 'Data Science', 'date': '2024-11-28'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              // Upload template logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Certificate Template Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 40, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Template', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Custom Template Name'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeTemplateScreen()));
                      },
                      child: Text('Change Template'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Eligible Students List
            Text('Eligible Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: eligibleStudents.length,
                itemBuilder: (context, index) {
                  final student = eligibleStudents[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.person, size: 40, color: Colors.blue),
                      title: Text(student['name']!),
                      subtitle: Text('Course: ${student['course']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_red_eye, color: Colors.green),
                            onPressed: () {
                              // Preview certificate logic
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.file_download, color: Colors.blue),
                            onPressed: () {
                              // Generate and issue certificate logic
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Issued Certificates List
            SizedBox(height: 16),
            ExpansionTile(
              title: Text('Issued Certificates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: issuedCertificates.map((certificate) {
                return ListTile(
                  title: Text(certificate['name']!),
                  subtitle: Text('Course: ${certificate['course']} \nDate: ${certificate['date']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      // Download certificate logic
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Bulk generate certificates logic
        },
        child: Icon(Icons.done_all),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
