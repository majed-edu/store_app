/// Form validators. Each returns an error message, or null when the value is fine.
class Validators {
  static String? requiredText(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? price(String? value) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null) return 'Enter a valid price, for example 29.99';
    if (number <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? imageUrl(String? value) {
    final uri = Uri.tryParse((value ?? '').trim());
    final isValid = uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
    return isValid ? null : 'Enter a full image link starting with https://';
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return ok ? null : 'Enter a valid email, like name@example.com';
  }

  static String? username(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Choose a username';
    if (text.length < 3) return 'Use at least 3 characters';
    if (text.contains(RegExp(r'\s'))) return "Username can't contain spaces";
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Repeat your password';
    if (value != original) return "Passwords don't match";
    return null;
  }
}
