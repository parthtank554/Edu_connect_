import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart';
import 'package:flutterpro/FirebaseServices/AuthenticationManager.dart';
import 'package:flutterpro/Screens/InstructorPanel/mainPanel.dart';
import 'package:flutterpro/Screens/authentication/ForgotPassword_screen.dart';
import 'package:flutterpro/Screens/authentication/Register_Screen.dart';
import 'package:flutterpro/Screens/StudentPanel/mainHomeScreen.dart';
import 'package:flutterpro/Screens/AdminPanel/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Custom_Widgets/CustomTextField.dart';
import '../../Custom_Widgets/GradientButton.dart';
import '../../Utils/Validations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isObscure = true;
  String _selectedRole = 'Student'; // Default role

  // Static admin credentials
  final String _adminEmail = 'admin@example.com';
  final String _adminPassword =
      'Admin@123'; // Updated to meet password requirements

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // Check for admin login
        if (_selectedRole == 'Admin') {
          if (email == _adminEmail && password == _adminPassword) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('userEmail', email);
            await prefs.setString('userRole', 'Admin');
            await prefs.setBool('isLoggedIn', true);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid admin credentials')),
            );
            return;
          }
        }

        // Regular user login
        var user =
            await _authService.loginWithEmailAndPassword(email, password);

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            String role = userDoc['role'] ?? 'student';

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('userEmail', user.email!);
            await prefs.setString('userRole', role);
            await prefs.setBool('isLoggedIn', true);

            if (role == 'Instructor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const mainPanel()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Mainhomescreen()),
              );
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn != null && isLoggedIn) {
      // User is logged in, navigate to the appropriate screen
      String? userRole = prefs.getString('userRole');
      String? userEmail = prefs.getString('userEmail');

      if (userRole == 'Admin' && userEmail == _adminEmail) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else if (userRole == 'Instructor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const mainPanel()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Mainhomescreen()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the screen is loaded
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          ConstantsText.ForgotPassword,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    Constants.logo,
                    height: 140,
                    width: 130,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  ConstantsText.LoginTitle,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ConstantsText.LoginSubtitle,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Role Selection
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'Student';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'Student',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Flexible(
                                  child: Text(
                                    'Student',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'Instructor';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'Instructor',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Flexible(
                                  child: Text(
                                    'Instructor',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'Admin';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'Admin',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Flexible(
                                  child: Text(
                                    'Admin',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Email Field
                CustomTextField(
                  hintText: ConstantsText.EmailID,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  maxLines: 1,
                  isRequired: true,
                  labelText: '',
                  controller: _emailController,
                  validator: Validation.validateEmail,
                ),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  hintText: ConstantsText.Password,
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscure,
                  maxLines: 1,
                  isRequired: true,
                  labelText: '',
                  controller: _passwordController,
                  validator: Validation.validatePassword,
                  toggleVisibility: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Forgot Password Button
                _buildForgotPasswordButton(context),

                const SizedBox(height: 24),

                // Login Button
                GradientButton(
                  buttonText: ConstantsText.Login,
                  onPressed: _handleLogin,
                  gradientColors: [
                    Colors.blueAccent.shade700,
                    Colors.blue.shade500,
                    Colors.lightBlueAccent.shade200,
                  ],
                  label: '',
                  child: Text(""),
                ),

                const Spacer(),

                // Register Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ConstantsText.DontHaveAccount,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ConstantsText.Register,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
