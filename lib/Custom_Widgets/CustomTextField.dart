import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String?)? onSaved;
  final FormFieldValidator<String>? validator;
  final VoidCallback? toggleVisibility;
  final TextEditingController? controller; // Add the controller parameter
  final int? maxLines;
  final bool enabled;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.obscureText,
    this.onSaved,
    this.validator,
    this.toggleVisibility,
    this.controller,
    this.maxLines,
    this.enabled = true,
    required bool isRequired,
    required String labelText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Use controller here
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      maxLength: maxLength ?? null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}
