import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía del design system (`specs/design-system.md`).
///
/// Familia sans-serif moderna y neutra: **Inter** (vía `google_fonts`).
/// La jerarquía se marca por **peso y tamaño, no por color**. Los números son
/// protagonistas (grandes y bold). El color base es [AppColors.textPrimary]; las
/// etiquetas tenues usan [AppColors.textSecondary].
abstract final class AppTypography {
  /// `TextTheme` completo basado en Inter, mapeando los tokens de la spec a los
  /// slots de Material que consumen los widgets por defecto.
  static TextTheme get textTheme {
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      // Dato clave protagonista (kcal del día, peso): grande + bold.
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      // Títulos de sección / pantalla.
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      // Texto normal de contenido.
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textPrimary,
      ),
      // Etiquetas tenues, pequeñas, pensadas para mayúsculas.
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }
}
