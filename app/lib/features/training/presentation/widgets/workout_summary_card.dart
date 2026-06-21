import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/workout_summary.dart';
import '../utils/workout_history_format.dart';
import '../utils/workout_session_format.dart';

/// Tarjeta de resumen de un workout en la lista de un día: nombre, duración (si
/// existe) y la línea "N ejercicios · M sets · X kg". Tocarla abre el detalle.
class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final WorkoutSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(summary.nombre, style: textTheme.headlineMedium),
                ),
                if (summary.duracionS != null) ...[
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    formatStopwatch(Duration(seconds: summary.duracionS!)),
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              formatSummaryLine(
                summary.numEjercicios,
                summary.numSets,
                summary.volumenTotal,
              ),
              style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
