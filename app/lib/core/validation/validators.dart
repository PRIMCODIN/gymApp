import 'password_policy.dart';

/// Validadores de formularios reutilizables, en Dart puro y testeable
/// (capa `core`, sin dependencias de Flutter ni Supabase).
///
/// Cada método devuelve `null` cuando el valor es válido, o un mensaje de error
/// en español cuando no lo es. Esa firma `String? Function(String?)` coincide con
/// `FormFieldValidator` de Flutter, así la UI puede enchufarlos directamente.
class Validators {
  const Validators._();

  /// Expresión razonable para validar el formato de un email.
  /// No pretende cubrir el RFC completo (imposible con regex); cubre los casos
  /// reales: algo@algo.dominio sin espacios.
  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );

  /// Valida un email: no vacío y con formato válido.
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Introduce tu email.';
    }
    if (!_emailRegExp.hasMatch(email)) {
      return 'El email no tiene un formato válido.';
    }
    return null;
  }

  /// Valida una contraseña contra [PasswordPolicy].
  /// No se hace `trim`: los espacios son caracteres válidos en una contraseña.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return PasswordPolicy.emptyMessage;
    }
    if (password.length < PasswordPolicy.minLength) {
      return PasswordPolicy.tooShortMessage;
    }
    if (PasswordPolicy.requireLetter && !password.contains(RegExp(r'[A-Za-z]'))) {
      return PasswordPolicy.missingLetterMessage;
    }
    if (PasswordPolicy.requireDigit && !password.contains(RegExp(r'[0-9]'))) {
      return PasswordPolicy.missingDigitMessage;
    }
    return null;
  }

  /// Valida que la confirmación coincida con la contraseña original.
  static String? confirmPassword(String? value, String? original) {
    if ((value ?? '').isEmpty) {
      return 'Repite la contraseña.';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Valida que el nombre no esté vacío.
  static String? name(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Introduce tu nombre.';
    }
    return null;
  }
}
