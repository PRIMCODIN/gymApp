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
/// El objetivo se lee de [dailyCalorieGoalProvider] y puede ser `null`:
/// - **mientras carga o si falla** → respaldo 2000 para no romper la vista (se
///   pinta la barra normal con un denominador provisional).
/// - **objetivo realmente sin fijar** (`data == null`) → estado vacío: se muestra
///   el consumido y los macros (eso sí se conoce), pero sin barra ni "te quedan X"
///   (no hay denominador) y con un aviso para fijarlo en Perfil.
/// Si se supera el objetivo, la barra se queda llena (el clamp vive en
/// [AppProgressBar]) y el número se resalta, sin romper el layout.
class CalorieSummaryCard extends ConsumerWidget {
  const CalorieSummaryCard({super.key, required this.totals});

  final DailyTotals totals;

  /// Respaldo cuando el objetivo aún se está cargando o falló (igual al default
  /// histórico de la BD). NO se usa para el caso "sin fijar", que es un `null`
  /// real y tiene su propia vista.
  static const int _fallbackGoal = 2000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // data null -> null (objetivo sin fijar); loading/error -> respaldo no-null.
    final goal = ref
        .watch(dailyCalorieGoalProvider)
        .maybeWhen(data: (value) => value, orElse: () => _fallbackGoal);

    return AppCard(
      child: goal == null
          ? _buildWithoutGoal(context)
          : _buildWithGoal(context, goal),
    );
  }

  /// Vista normal: barra consumido / objetivo + restantes/excedido + macros.
  Widget _buildWithGoal(BuildContext context, int goal) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    final consumed = totals.kcal.round();
    final exceeded = consumed > goal;
    final progress = goal <= 0 ? 0.0 : consumed / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('CALORÍAS DEL DÍA', style: textTheme.labelSmall),
            Text(
              '$consumed / $goal kcal',
              style: textTheme.labelLarge?.copyWith(
                color: exceeded ? palette.accentNutrition : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        AppProgressBar(value: progress, context: AppProgressContext.calories),
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
          Text('Te quedan ${goal - consumed} kcal', style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.l),
        MacroSummary(totals: totals),
      ],
    );
  }

  /// Estado vacío (objetivo sin fijar): consumido + macros, sin barra ni
  /// "restantes" (no hay denominador). Aviso discreto para fijarlo en Perfil.
  Widget _buildWithoutGoal(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    final consumed = totals.kcal.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('CALORÍAS DEL DÍA', style: textTheme.labelSmall),
            Text('$consumed kcal', style: textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Fija tu objetivo de calorías en Perfil',
          style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.l),
        MacroSummary(totals: totals),
      ],
    );
  }
}
