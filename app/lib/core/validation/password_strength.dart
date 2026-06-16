/// Evaluación de la *fuerza* de una contraseña, en Dart puro y testeable
/// (capa `core`, sin dependencias de Flutter ni Supabase).
///
/// Es independiente de la *validación* (`validators.dart`): una contraseña puede
/// ser válida (pasa la política) y aun así tener fuerza media. Aquí solo se
/// calcula el nivel; la UI pintará una barra a partir de [PasswordStrengthResult].
library;

/// Nivel de fuerza de una contraseña.
enum PasswordStrength { weak, medium, strong }

/// Resultado de evaluar una contraseña: nivel, puntuación normalizada y etiqueta.
class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.label,
  });

  /// Nivel cualitativo.
  final PasswordStrength level;

  /// Puntuación normalizada en el rango 0.0–1.0, pensada para pintar una barra.
  final double score;

  /// Etiqueta legible en español (`Débil` / `Media` / `Fuerte`).
  final String label;
}

/// Evalúa la fuerza de [password] combinando varios criterios.
///
/// Criterios que suman puntos: longitud (>= mínimo y >= 12), presencia de
/// minúsculas, mayúsculas, dígitos y símbolos. La puntuación se normaliza y se
/// mapea a un nivel. Una contraseña vacía es siempre [PasswordStrength.weak].
PasswordStrengthResult evaluatePasswordStrength(String password) {
  if (password.isEmpty) {
    return const PasswordStrengthResult(
      level: PasswordStrength.weak,
      score: 0.0,
      label: 'Débil',
    );
  }

  var points = 0;
  const maxPoints = 6;

  // Longitud: un punto por superar el mínimo razonable y otro por ser larga.
  if (password.length >= 8) points++;
  if (password.length >= 12) points++;

  // Variedad de caracteres.
  if (password.contains(RegExp(r'[a-z]'))) points++;
  if (password.contains(RegExp(r'[A-Z]'))) points++;
  if (password.contains(RegExp(r'[0-9]'))) points++;
  if (password.contains(RegExp(r'[^A-Za-z0-9]'))) points++;

  final score = points / maxPoints;

  final PasswordStrength level;
  final String label;
  if (score < 0.5) {
    level = PasswordStrength.weak;
    label = 'Débil';
  } else if (score < 0.8) {
    level = PasswordStrength.medium;
    label = 'Media';
  } else {
    level = PasswordStrength.strong;
    label = 'Fuerte';
  }

  return PasswordStrengthResult(level: level, score: score, label: label);
}
