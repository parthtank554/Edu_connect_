import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart'; // Import ConstantsText
import 'package:flutterpro/Custom_Widgets/CustomTextField.dart'; // Import CustomTextField
import 'package:flutterpro/Custom_Widgets/GradientButton.dart'; // Import GradientButton
import '../../Utils/Validations.dart'; // Import Validation class

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _passwordController.text.trim();

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // Reauthenticate the user
        await user.reauthenticateWithCredential(cred);

        // Change password
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );

        // Clear fields
        _currentPasswordController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'wrong-password':
            message = 'Incorrect current password.';
            break;
          default:
            message = 'An error occurred. Please try again later.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(ConstantsText.ChangePassword),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Password
              CustomTextField(
                hintText: 'Current Password',
                icon: Icons.lock,
                obscureText: _obscureCurrentPassword,
                maxLines: 1,
                keyboardType: TextInputType.text,
                controller: _currentPasswordController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter current password' : null,
                toggleVisibility: _toggleCurrentPasswordVisibility, isRequired: true, labelText: '',
              ),
              const SizedBox(height: 20),

              // New Password
              CustomTextField(
                hintText: ConstantsText.Password,
                icon: Icons.lock,
                obscureText: _obscurePassword,
                maxLines: 1,
                keyboardType: TextInputType.text,
                controller: _passwordController,
                validator: (value) => Validation.validatePassword(value),
                toggleVisibility: _togglePasswordVisibility, isRequired: true, labelText: '',
              ),
              const SizedBox(height: 20),

              // Confirm Password
              CustomTextField(
                hintText: ConstantsText.ConfirmPassword,
                icon: Icons.lock,
                obscureText: _obscureConfirmPassword,
                maxLines: 1,
                keyboardType: TextInputType.text,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                toggleVisibility: _toggleConfirmPasswordVisibility, isRequired: true, labelText: '',
              ),
              const SizedBox(height: 30),

              // Submit Button
              GradientButton(
                buttonText: ConstantsText.ChangePassword,
                onPressed: _changePassword,
                gradientColors: [
                  Colors.blueAccent.shade700,
                  Colors.blue.shade500,
                  Colors.lightBlueAccent.shade200,
                ], label: '',child: Text(""), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
