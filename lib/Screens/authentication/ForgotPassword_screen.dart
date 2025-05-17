import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart';
import 'package:flutterpro/Custom_Widgets/CustomTextField.dart';
import 'package:flutterpro/Custom_Widgets/GradientButton.dart';
import 'package:flutterpro/Utils/Validations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Custom_Widgets/CircularProgressIndicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _sendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email.'),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  Constants.logo, // Update to your app's logo
                  height: 180,
                  width: 160,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                ConstantsText.ForgotPassword,
                style: TextStyle(
                  fontSize: 28.0, // Adjusted to match LoginScreen
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ConstantsText.ForgotPasswordSubtitle,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: CustomTextField(
                  hintText: ConstantsText.EmailID,
                  icon: Icons.email,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  controller: _emailController,
                  validator: (value) => Validation.validateEmail(value),
                  isRequired: true,
                  labelText: '',
                ),
              ),
              const SizedBox(height: 30),
              GradientButton(
                buttonText: ConstantsText.SendLink,
                // Instead of passing null when loading, pass an empty function
                onPressed: _isLoading ? () {} : _sendResetLink,
                gradientColors: [
                  Colors.blueAccent.shade700,
                  Colors.blue.shade500,
                  Colors.lightBlueAccent.shade200,
                ],
                label: '',
                child: Text(""),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Add logic for resending the link if needed
                  },
                  child: const Text(
                    ConstantsText.ResendLink,
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              if (_isLoading)
                const CustomCircularProgressIndicator(
                  // Using custom indicator
                  size: 70, // Custom size
                  gradientColors: [
                    Colors.blueAccent,
                    Colors.green
                  ], // Custom gradient colors
                  strokeWidth: 6, // Custom stroke width
                  showBackgroundCircle: true, // Background circle
                ),
            ],
          ),
        ),
      ),
    );
  }
}
