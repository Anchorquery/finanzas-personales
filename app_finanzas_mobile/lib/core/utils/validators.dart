/// Shared input validators.
class Validators {
  Validators._();

  /// RFC-5322-inspired email regex. Client-side gate only — server must re-validate.
  static final RegExp _email =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  /// Returns null if valid, or error message for Form fields.
  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Correo requerido';
    if (!isValidEmail(v)) return 'Correo inválido';
    return null;
  }

  static String? requiredText(String? value, {String label = 'Campo'}) {
    if ((value ?? '').trim().isEmpty) return '$label requerido';
    return null;
  }

  static String? positiveAmount(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Monto requerido';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null) return 'Monto inválido';
    if (parsed <= 0) return 'Debe ser mayor que cero';
    return null;
  }

  static String? minLengthText(String? value, int min, {String label = 'Campo'}) {
    final v = value ?? '';
    if (v.length < min) return '$label debe tener al menos $min caracteres';
    return null;
  }
}
