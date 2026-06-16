/// Política de contraseña del proyecto, centralizada en un único sitio.
///
/// Es la fuente de verdad compartida por [Validators] (qué bloquea el envío) y
/// por la evaluación de fuerza (`password_strength.dart`). Dart puro, sin
/// dependencias de Flutter ni Supabase (capa `core`, ver
/// `specs/languageArchitecture.md`).
///
/// Política MVP:
/// - Mínimo [minLength] caracteres.
/// - Al menos una letra y un dígito (requisito que bloquea el registro).
/// - Mayúsculas/minúsculas y símbolos NO son obligatorios, pero suman a la
///   *fuerza* de la contraseña (ver `password_strength.dart`).
///
/// IMPORTANTE: [minLength] debe coincidir con el mínimo configurado en Supabase
/// Auth. Si no coinciden, el servidor rechazaría contraseñas que el cliente
/// considera válidas (o al revés).
class PasswordPolicy {
  const PasswordPolicy._();

  /// Longitud mínima exigida.
  static const int minLength = 8;

  /// Si exige al menos una letra (a–z, A–Z).
  static const bool requireLetter = true;

  /// Si exige al menos un dígito (0–9).
  static const bool requireDigit = true;

  // --- Mensajes de error en español (centralizados para la UI) ---

  static const String emptyMessage = 'Introduce una contraseña.';

  static const String tooShortMessage =
      'La contraseña debe tener al menos $minLength caracteres.';

  static const String missingLetterMessage =
      'La contraseña debe incluir al menos una letra.';

  static const String missingDigitMessage =
      'La contraseña debe incluir al menos un número.';
}
