// validation.dart
class Validation {
  // Validate Full Name
// Validate Full Name (First Name, Middle Name, Last Name)
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full Name is required';
    }

    // Split the full name into parts
    List<String> nameParts = value.trim().split(RegExp(r'\s+'));

    if (nameParts.length < 2) {
      return 'Full Name must include at least a first name and a last name';
    }

    // Optional: Ensure each part is alphabetic
    for (String part in nameParts) {
      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
        return 'Each part of the name must contain only alphabets';
      }
    }

    return null;
  }

  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Email regex pattern
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate Password with Regex
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Password regex pattern to check:
    // At least one uppercase letter, one lowercase letter, one number, one special character, and a minimum length of 8 characters.
    String passwordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regExp = RegExp(passwordPattern);

    if (!regExp.hasMatch(value)) {
      return 'Password must contain at least: \n1. One uppercase letter\n2. One lowercase letter\n3. One digit\n4. One special character (@, !, %, *, ?, &)\n5. Minimum length of 8 characters';
    }
    return null;
  }

  // Validate Confirm Password
  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm Password is required';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
