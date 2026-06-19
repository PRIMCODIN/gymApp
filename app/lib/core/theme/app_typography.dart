import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografía del design system (`specs/design-system.md`).
///
/// Familia sans-serif moderna y neutra: **Inter**, empaquetada como asset
/// (`assets/fonts/Inter-Variable.ttf`, declarada en `pubspec.yaml`). Se usa la
/// fuente variable, así que el peso se selecciona vía `fontWeight`.
///
/// La jerarquía se marca por **peso y tamaño, no por color**. Los números son
/// protagonistas (grandes y bold). El color base es [AppColors.textPrimary]; las
/// etiquetas tenues usan [AppColors.textSecondary].
abstract final class AppTypography {
  /// Nombre de la familia declarada en `pubspec.yaml`.
  static const String _fontFamily = 'Inter';

  /// `TextTheme` completo basado en Inter, mapeando los tokens de la spec a los
  /// slots de Material que consumen los widgets por defecto. Los slots extra
  /// (`bodySmall`, `labelLarge`, `labelMedium`) cubren los tamaños pequeños del
  /// mockup (inputs, subtítulos, micro-textos de pie).
  static TextTheme get textTheme {
    return const TextTheme(
      // Dato clave protagonista (kcal del día, peso): grande + bold.
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      // Títulos de sección / pantalla.
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      // Texto normal de contenido.
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textPrimary,
      ),
      // Texto secundario pequeño: texto de inputs, subtítulos tenues.
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
      // Texto de botón.
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      // Micro-textos de pie (enlaces, separadores).
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textSecondary,
      ),
      // Etiquetas tenues, pequeñas, pensadas para mayúsculas.
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }
}
