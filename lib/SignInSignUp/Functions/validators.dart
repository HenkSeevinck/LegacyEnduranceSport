import 'package:email_validator/email_validator.dart';

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!EmailValidator.validate(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must have at least one uppercase letter, one special character and one number';
  }
  if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
    return 'Password must have at least one uppercase letter, one special character and one number';
  }
  if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
    return 'Password must have at least one uppercase letter, one special character and one number';
  }
  if (!RegExp(r'^(?=.*[!@#\$&*~_.,;:])').hasMatch(value)) {
    return 'Password must have at least one uppercase letter, one special character and one number';
  }
  return null;
}

String? reEnterPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Re-entering password is required';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
