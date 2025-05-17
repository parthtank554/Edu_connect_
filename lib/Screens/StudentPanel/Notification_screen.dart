import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with your actual notification count
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 24,
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification ${index + 1}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const Text(
                        'This is a sample notification description.',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      Text(
                        'Timestamp: ${DateTime.now()}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
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
