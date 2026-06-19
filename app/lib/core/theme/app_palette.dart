import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens semánticos del design system que no encajan en los slots estándar de
/// [ColorScheme] (acentos training/nutrition y neutros extra).
///
/// Se exponen como [ThemeExtension] para que los componentes los lean con
/// `Theme.of(context).extension<AppPalette>()!` (o `context.palette`). Añadir un
/// modo claro en el futuro = crear otra instancia ([AppPalette.dark] + light),
/// sin tocar ninguna pantalla.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.accentTraining,
    required this.accentTrainingDeep,
    required this.accentNutrition,
    required this.accentNutritionSoft,
    required this.surfaceElevated,
    required this.divider,
    required this.textSecondary,
    required this.textTertiary,
  });

  /// Paleta del modo oscuro (única por ahora; el sistema es dark-only).
  static const AppPalette dark = AppPalette(
    accentTraining: AppColors.accentTraining,
    accentTrainingDeep: AppColors.accentTrainingDeep,
    accentNutrition: AppColors.accentNutrition,
    accentNutritionSoft: AppColors.accentNutritionSoft,
    surfaceElevated: AppColors.surfaceElevated,
    divider: AppColors.divider,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
  );

  final Color accentTraining;
  final Color accentTrainingDeep;
  final Color accentNutrition;
  final Color accentNutritionSoft;
  final Color surfaceElevated;
  final Color divider;
  final Color textSecondary;
  final Color textTertiary;

  @override
  AppPalette copyWith({
    Color? accentTraining,
    Color? accentTrainingDeep,
    Color? accentNutrition,
    Color? accentNutritionSoft,
    Color? surfaceElevated,
    Color? divider,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppPalette(
      accentTraining: accentTraining ?? this.accentTraining,
      accentTrainingDeep: accentTrainingDeep ?? this.accentTrainingDeep,
      accentNutrition: accentNutrition ?? this.accentNutrition,
      accentNutritionSoft: accentNutritionSoft ?? this.accentNutritionSoft,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      divider: divider ?? this.divider,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      accentTraining: Color.lerp(accentTraining, other.accentTraining, t)!,
      accentTrainingDeep:
          Color.lerp(accentTrainingDeep, other.accentTrainingDeep, t)!,
      accentNutrition: Color.lerp(accentNutrition, other.accentNutrition, t)!,
      accentNutritionSoft:
          Color.lerp(accentNutritionSoft, other.accentNutritionSoft, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

/// Acceso ergonómico a la paleta semántica desde un [BuildContext].
extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
