class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Only valid Gmail addresses allowed';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Minimum 8 characters required';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'At least one uppercase letter required';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'At least one number required';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'At least one special character required';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Enter a valid number';
    }

    if (age < 18 || age > 100) {
      return 'Age must be between 18 and 100';
    }

    return null;
  }
}
