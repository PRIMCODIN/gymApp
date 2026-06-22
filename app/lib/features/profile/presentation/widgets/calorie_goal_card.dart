import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// Tarjeta del objetivo de kcal diario: el número en grande (acento naranja),
/// la unidad y un icono de edición. Toda la tarjeta es tappable para editar.
/// Si el objetivo aún no está fijado (`kcalGoal == null`) muestra un estado
/// vacío («Sin fijar») en vez de un número inventado.
class CalorieGoalCard extends StatelessWidget {
  const CalorieGoalCard({
    super.key,
    required this.kcalGoal,
    required this.onEdit,
  });

  final int? kcalGoal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final goal = kcalGoal;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBJETIVO DIARIO', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  if (goal == null)
                    Text(
                      'Sin fijar',
                      style: textTheme.displayLarge?.copyWith(
                        color: palette.textSecondary,
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          goal.toString(),
                          style: textTheme.displayLarge?.copyWith(
                            color: palette.accentNutrition,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s),
                          child: Text(
                            'kcal',
                            style: textTheme.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, color: palette.textSecondary),
          ],
        ),
      ),
    );
  }
}
