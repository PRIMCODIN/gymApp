import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Theme central de la app (`specs/design-system.md`).
///
/// Ensambla todos los tokens en un [ThemeData] oscuro completo. Dark-only por
/// ahora: cuando exista un modo claro, se añade aquí un `AppTheme.light` con su
/// propia [AppPalette], sin tocar pantallas.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accentTraining,
      onPrimary: AppColors.background,
      secondary: AppColors.accentNutrition,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFEF4444),
      onError: AppColors.textPrimary,
      outline: AppColors.divider,
    );

    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,
      textTheme: textTheme,
      extensions: const [AppPalette.dark],
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.m,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s + AppSpacing.xs,
        ),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        errorStyle: textTheme.labelMedium?.copyWith(color: colorScheme.error),
        // Borde sutil de 0.5px en gris `divider`; foco en teal. Sin líneas duras.
        border: _inputBorder(AppColors.divider, 0.5),
        enabledBorder: _inputBorder(AppColors.divider, 0.5),
        focusedBorder: _inputBorder(AppColors.accentTraining, 1),
        errorBorder: _inputBorder(colorScheme.error, 0.5),
        focusedErrorBorder: _inputBorder(colorScheme.error, 1),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentTraining,
          textStyle: textTheme.labelMedium?.copyWith(
            color: AppColors.accentTraining,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
