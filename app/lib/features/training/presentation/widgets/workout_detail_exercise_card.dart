import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/workout_detail.dart';
import '../utils/muscle_groups.dart';

/// Tarjeta de un ejercicio en el detalle (solo lectura): nombre + grupo muscular y
/// su tabla de sets [SET · KG · REPS · ✓]. Los flex de las columnas se comparten
/// entre la cabecera y las filas para mantener la alineación.
class WorkoutDetailExerciseCard extends StatelessWidget {
  const WorkoutDetailExerciseCard({super.key, required this.exercise});

  final WorkoutDetailExercise exercise;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            exercise.nombreEjercicio,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            muscleGroupLabel(exercise.grupoMuscular),
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s),
          const _SetTableHeader(),
          for (final set in exercise.sets)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: _SetRow(set: set),
            ),
        ],
      ),
    );
  }
}

/// Flex de las cuatro columnas de la tabla de sets (compartido por cabecera/fila).
const int _flexSet = 1;
const int _flexKg = 2;
const int _flexReps = 2;
const int _flexCheck = 1;

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.palette.textSecondary,
    );

    return Row(
      children: [
        Expanded(flex: _flexSet, child: Text('SET', style: style)),
        Expanded(flex: _flexKg, child: Text('KG', style: style)),
        Expanded(flex: _flexReps, child: Text('REPS', style: style)),
        Expanded(
          flex: _flexCheck,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('✓', style: style),
          ),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set});

  final WorkoutDetailSet set;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final style = textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(flex: _flexSet, child: Text('${set.numSet}', style: style)),
        Expanded(flex: _flexKg, child: Text(_format(set.peso), style: style)),
        Expanded(
          flex: _flexReps,
          child: Text(_format(set.reps), style: style),
        ),
        Expanded(
          flex: _flexCheck,
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              set.completado ? Icons.check_circle : Icons.remove,
              size: AppSpacing.m,
              color: set.completado
                  ? palette.accentTraining
                  : palette.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra el valor o un guion si es null (set a medias). Los pesos enteros se
  /// muestran sin el `.0` final.
  String _format(num? value) {
    if (value == null) return '–';
    if (value is double && value == value.roundToDouble()) {
      return '${value.toInt()}';
    }
    return '$value';
  }
}
