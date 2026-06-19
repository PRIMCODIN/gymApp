import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../validation/password_strength.dart';

/// Barra de fuerza de contraseña. Pinta el nivel que YA calcula la lógica
/// existente ([evaluatePasswordStrength] en `core/validation`): este widget solo
/// renderiza, no reimplementa el cálculo.
///
/// Se oculta cuando la contraseña está vacía. El color sale de la [AppPalette]:
/// débil = error, media = naranja de nutrición, fuerte = teal de entreno.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final result = evaluatePasswordStrength(password);
    final palette = context.palette;
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (result.level) {
      PasswordStrength.weak => colorScheme.error,
      PasswordStrength.medium => palette.accentNutritionSoft,
      PasswordStrength.strong => palette.accentTraining,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: LinearProgressIndicator(
              value: result.score,
              minHeight: AppSpacing.xs + 2,
              color: color,
              backgroundColor: palette.surfaceElevated,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seguridad: ${result.label}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
