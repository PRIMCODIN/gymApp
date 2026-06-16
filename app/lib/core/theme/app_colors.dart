import 'package:flutter/painting.dart';

/// Tokens de color crudos del design system (`specs/design-system.md`).
///
/// Son los valores hex EXACTOS de la spec. No deben consumirse directamente en
/// las pantallas: se exponen a través del [ThemeData] central y de [AppPalette].
/// Cambiar un color = cambiarlo aquí y se actualiza toda la app.
abstract final class AppColors {
  // Acentos semánticos.
  /// Teal. Acento principal de entreno.
  static const Color accentTraining = Color(0xFF2DD4BF);

  /// Teal profundo. Fondos / estados activos de entreno.
  static const Color accentTrainingDeep = Color(0xFF0D9488);

  /// Zanahoria. Acento principal de nutrición.
  static const Color accentNutrition = Color(0xFFF97316);

  /// Naranja suave. Texto/iconos pequeños sobre oscuro.
  static const Color accentNutritionSoft = Color(0xFFFB923C);

  // Neutros / fondos (modo oscuro).
  /// Fondo base (gris muy oscuro, no negro puro).
  static const Color background = Color(0xFF0F1115);

  /// Superficie / tarjetas.
  static const Color surface = Color(0xFF1A1D23);

  /// Superficie elevada / inputs.
  static const Color surfaceElevated = Color(0xFF252931);

  /// Separadores sutiles.
  static const Color divider = Color(0xFF2E323B);

  /// Texto principal.
  static const Color textPrimary = Color(0xFFF5F6F7);

  /// Texto secundario / etiquetas.
  static const Color textSecondary = Color(0xFF9CA3AF);
}
