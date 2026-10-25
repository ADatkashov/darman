/// Pure validators; return an error *kind* that the UI maps to a localized message.
enum FieldError { required, phone, password, email, otp }

abstract final class Validators {
  static String? normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && (digits.startsWith('8') || digits.startsWith('7'))) {
      digits = '7${digits.substring(1)}';
    } else if (digits.length == 10) {
      digits = '7$digits';
    } else {
      return null;
    }
    return '+$digits';
  }

  static FieldError? phone(String? v) => v == null || v.trim().isEmpty
      ? FieldError.required
      : normalizePhone(v) == null
      ? FieldError.phone
      : null;

  static FieldError? required(String? v) => v == null || v.trim().isEmpty ? FieldError.required : null;

  static FieldError? password(String? v) {
    if (v == null || v.isEmpty) return FieldError.required;
    final hasLetter = RegExp(r'\p{L}', unicode: true).hasMatch(v);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    return v.length >= 8 && hasLetter && hasDigit ? null : FieldError.password;
  }

  static FieldError? optionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? null : FieldError.email;
  }

  static FieldError? otp(String? v) => v != null && RegExp(r'^\d{4,8}$').hasMatch(v.trim()) ? null : FieldError.otp;

  /// "+77011234567" -> "+7 701 123 45 67"
  static String prettyPhone(String e164) {
    final d = e164.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 11) return e164;
    return '+${d[0]} ${d.substring(1, 4)} ${d.substring(4, 7)} ${d.substring(7, 9)} ${d.substring(9)}';
  }
}
