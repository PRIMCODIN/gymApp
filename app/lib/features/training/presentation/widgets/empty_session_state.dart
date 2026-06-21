import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';

/// Estado vacío de la sesión: aún no hay ejercicios. Invita a añadir el primero.
class EmptySessionState extends StatelessWidget {
  const EmptySessionState({super.key, required this.onAddExercise});

  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: AppSpacing.xl,
              color: palette.textSecondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Empieza añadiendo tu primer ejercicio.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: 'Añadir ejercicio',
              onPressed: onAddExercise,
            ),
          ],
        ),
      ),
    );
  }
}
