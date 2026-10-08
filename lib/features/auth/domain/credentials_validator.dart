enum EmailError { empty, invalid }

enum PasswordError { empty, tooShort }

class CredentialsValidator {
  const CredentialsValidator._();

  static const minPasswordLength = 6;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static EmailError? validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return EmailError.empty;
    if (!_emailPattern.hasMatch(value)) return EmailError.invalid;
    return null;
  }

  static PasswordError? validatePassword(String password) {
    if (password.isEmpty) return PasswordError.empty;
    if (password.length < minPasswordLength) return PasswordError.tooShort;
    return null;
  }
}
