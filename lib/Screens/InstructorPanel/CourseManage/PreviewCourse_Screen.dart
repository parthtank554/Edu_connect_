import 'package:flutter/material.dart';

class CoursePreviewScreen extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String category;
  final String format;
  final List<Map<String, String>> lessons;

  const CoursePreviewScreen({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.format,
    required this.lessons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Course'),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Title and Category
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Chip(
              label: Text(category),
              backgroundColor: Colors.blue.shade100,
            ),
            SizedBox(height: 16),

            // Description
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Course Format and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Format: $format',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  '\$$price',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Lessons Overview
            Text(
              'Lessons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            lessons.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return ListTile(
                  leading: Icon(Icons.play_circle_fill, color: Colors.blue),
                  title: Text(lesson['title']!),
                  subtitle: Text(lesson['duration']!),
                );
              },
            )
                : Center(
              child: Text(
                'No lessons added yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
