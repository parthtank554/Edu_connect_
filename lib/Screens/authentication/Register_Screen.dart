import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/FirebaseServices/AuthenticationManager.dart';
import 'package:flutterpro/FirebaseServices/FirestoreManager.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import '../../Custom_Widgets/CustomTextField.dart';
import '../../Utils/Validations.dart';
import '../../Custom_Widgets/GradientButton.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreManager _firestoreService = FirestoreManager();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String _selectedRole = 'Student';
  // Handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String fullName = _fullNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // Register user with Firebase Authentication
        var user =
            await _authService.registerWithEmailAndPassword(email, password);

        if (user != null) {
          // Add user details to Firestore
          await _firestoreService.addUserToFirestore(user.uid, {
            'fullName': fullName,
            'email': email,
            'uid': user.uid,
            'role': _selectedRole,
            'createdAt': DateTime.now().toIso8601String(),
});

          // Navigate to login or home screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        // Handle errors (e.g., show Snackbar with error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when screen is disposed
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    Constants.logo,
                    height: 180,
                    width: 160,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  ConstantsText.CreateAcccountTitle,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ConstantsText.CreateAcccountSubtitle,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name Field
                CustomTextField(
                  hintText: ConstantsText.FullName,
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                  obscureText: false,isRequired: true, labelText: '',
                  maxLines: 1,
                  onSaved: (value) => _fullNameController.text = value!,
                  validator: Validation.validateFullName,
                ),

                const SizedBox(height: 20),
                // Email Field
                CustomTextField(
                  hintText: ConstantsText.EmailID,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,isRequired: true, labelText: '',
                  maxLines: 1,
                  onSaved: (value) => _emailController.text = value!,
                  validator: Validation.validateEmail,
                ),

                const SizedBox(height: 20),
                // Password Field
                CustomTextField(
                  hintText: ConstantsText.Password,
                  icon: Icons.lock,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isPasswordObscured,
                  maxLines: 1,isRequired: true, labelText: '',
                  onSaved: (value) => _passwordController.text = value!,
                  validator: Validation.validatePassword,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),

                const SizedBox(height: 20),
                // Confirm Password Field
                CustomTextField(
                  hintText: ConstantsText.ConfirmPassword,
                  icon: Icons.lock,isRequired: true, labelText: '',
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isConfirmPasswordObscured,
                  maxLines: 1,
                  onSaved: (value) => _confirmPasswordController.text = value!,
                  // validator: (value) {
                  //   return Validation.validateConfirmPassword(
                  //       _passwordController.text, value);
                  // },
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),

                const SizedBox(height: 30),
               Text(
                  'Select Role',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Student',
                      groupValue: _selectedRole,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    Text(
                      'Student',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Instructor',
                      groupValue: _selectedRole,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    Text(
                      'Instructor',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                GradientButton(
                  buttonText: ConstantsText.Register,
                  onPressed: _submitForm,
                  gradientColors: [
                    Colors.blueAccent.shade700,
                    Colors.blue.shade500,
                    Colors.lightBlueAccent.shade200,
                  ], label: '',child: Text(""), 
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ConstantsText.HaveAccount,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          ConstantsText.Login,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
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
