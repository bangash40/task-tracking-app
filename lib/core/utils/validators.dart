class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length > 100) return 'Title must be 100 characters or less';
    return null;
  }

  static String? description(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must be 500 characters or less';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
