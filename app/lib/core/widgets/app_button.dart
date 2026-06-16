import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

/// Variante semántica del botón (`specs/design-system.md`).
enum AppButtonVariant {
  /// Acción de entreno (teal).
  training,

  /// Acción de nutrición (naranja).
  nutrition,

  /// Acción secundaria / neutra (sobre `surfaceElevated`).
  neutral,
}

/// Botón principal reutilizable. Toma todos sus colores y tamaños del theme y de
/// la [AppPalette]; nunca hex ni tamaños sueltos.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.training,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Muestra un spinner y deshabilita el botón mientras hay una acción en curso.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final isNeutral = variant == AppButtonVariant.neutral;
    final background = switch (variant) {
      AppButtonVariant.training => palette.accentTraining,
      AppButtonVariant.nutrition => palette.accentNutrition,
      AppButtonVariant.neutral => palette.surfaceElevated,
    };
    // Sobre los acentos vivos el texto oscuro contrasta mejor; en neutro, claro.
    final foreground = isNeutral ? AppColors.textPrimary : AppColors.background;

    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: isDisabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.4),
          disabledForegroundColor: foreground.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.m),
          ),
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSpacing.l,
                width: AppSpacing.l,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            : Text(label),
      ),
    );
  }
}
