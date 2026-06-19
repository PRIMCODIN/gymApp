import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../domain/entities/daily_totals.dart';
import '../state/daily_nutrition_providers.dart';
import 'macro_summary.dart';

/// Tarjeta de resumen del día: barra de progreso de calorías (total / objetivo),
/// el número visible y el desglose de macros.
///
/// El objetivo se lee de [dailyCalorieGoalProvider]; mientras carga (o si falla)
/// se usa 2000 como respaldo para no bloquear la vista. Si se supera el objetivo,
/// la barra se queda llena (el clamp vive en [AppProgressBar]) y el número se
/// resalta, sin romper el layout.
class CalorieSummaryCard extends ConsumerWidget {
  const CalorieSummaryCard({super.key, required this.totals});

  final DailyTotals totals;

  /// Respaldo cuando aún no hay objetivo cargado (igual al default de la BD).
  static const int _fallbackGoal = 2000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    final goal = ref
        .watch(dailyCalorieGoalProvider)
        .maybeWhen(data: (value) => value, orElse: () => _fallbackGoal);

    final consumed = totals.kcal.round();
    final exceeded = consumed > goal;
    final progress = goal <= 0 ? 0.0 : consumed / goal;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('CALORÍAS DE HOY', style: textTheme.labelSmall),
              Text(
                '$consumed / $goal kcal',
                style: textTheme.labelLarge?.copyWith(
                  color: exceeded ? palette.accentNutrition : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          AppProgressBar(
            value: progress,
            context: AppProgressContext.calories,
          ),
          const SizedBox(height: AppSpacing.s),
          // Restantes vs exceso son mutuamente excluyentes: o te quedan kcal o ya
          // pasaste del objetivo.
          if (exceeded)
            Text(
              'Has superado tu objetivo en ${consumed - goal} kcal.',
              style: textTheme.bodySmall?.copyWith(
                color: palette.accentNutritionSoft,
              ),
            )
          else
            Text(
              'Te quedan ${goal - consumed} kcal',
              style: textTheme.bodySmall,
            ),
          const SizedBox(height: AppSpacing.l),
          MacroSummary(totals: totals),
        ],
      ),
    );
  }
}
