import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.privacy_tip,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Account information (name, email, profile picture)\n'
                  '• Course enrollment and progress data\n'
                  '• Quiz and assessment results\n'
                  '• Communication preferences',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the collected information to:\n\n'
                  '• Provide and improve our educational services\n'
                  '• Personalize your learning experience\n'
                  '• Track your progress and performance\n'
                  '• Send important updates and notifications\n'
                  '• Ensure platform security and prevent fraud',
            ),
            _buildSection(
              '3. Data Security',
              'We implement appropriate security measures to protect your personal information:\n\n'
                  '• Encryption of data in transit and at rest\n'
                  '• Regular security audits\n'
                  '• Access controls and authentication\n'
                  '• Secure data storage practices',
            ),
            _buildSection(
              '4. Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Request correction of inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of marketing communications\n'
                  '• Withdraw consent for data processing',
            ),
            _buildSection(
              '5. Cookies and Tracking',
              'We use cookies and similar technologies to:\n\n'
                  '• Remember your preferences\n'
                  '• Analyze platform usage\n'
                  '• Improve user experience\n'
                  '• Provide personalized content',
            ),
            const SizedBox(height: 20),
            const Text(
              'Last Updated: March 2024',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
