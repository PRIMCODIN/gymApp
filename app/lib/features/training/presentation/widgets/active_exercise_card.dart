import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/active_exercise.dart';
import '../../domain/entities/previous_set_performance.dart';
import '../state/active_workout_controller.dart';
import '../state/workout_session_providers.dart';
import '../utils/muscle_groups.dart';
import '../utils/workout_session_format.dart';
import 'active_set_row.dart';

/// Tarjeta de un ejercicio dentro de la sesión: cabecera (nombre + grupo
/// muscular + quitar) y la tabla de sets con su columna PREVIOUS. Cablea cada
/// acción del set al [ActiveWorkoutController].
class ActiveExerciseCard extends ConsumerWidget {
  const ActiveExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
  });

  /// Posición del ejercicio en la sesión (para dirigir las acciones del notifier).
  final int index;
  final ActiveExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(activeWorkoutControllerProvider.notifier);
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    // PREVIOUS del ejercicio (última sesión finalizada con este exercise_id).
    final previousAsync =
        ref.watch(previousPerformanceProvider(exercise.exerciseId));

    String previousLabelFor(int numSet) {
      return previousAsync.when(
        loading: () => '…',
        error: (_, _) => '—',
        data: (sets) => _formatPrevious(previousForSet(sets, numSet)),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.nombre, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      muscleGroupLabel(exercise.grupoMuscular),
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmRemove(context, controller),
                tooltip: 'Quitar ejercicio',
                icon: Icon(Icons.delete_outline, color: palette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          const _SetTableHeader(),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < exercise.sets.length; i++)
            ActiveSetRow(
              key: ValueKey('set-${exercise.sets[i].uid}'),
              uid: exercise.sets[i].uid,
              numSet: exercise.sets[i].numSet,
              reps: exercise.sets[i].reps,
              peso: exercise.sets[i].peso,
              completado: exercise.sets[i].completado,
              previousLabel: previousLabelFor(exercise.sets[i].numSet),
              onRepsChanged: (reps) => controller.updateSetReps(index, i, reps),
              onPesoChanged: (peso) => controller.updateSetPeso(index, i, peso),
              onToggle: () => controller.toggleCompletado(index, i),
              onRemove: () => controller.removeSet(index, i),
            ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => controller.addSet(index),
              icon: const Icon(Icons.add, size: AppSpacing.m),
              label: const Text('Añadir set'),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirma antes de quitar el ejercicio (no es borrado silencioso).
  Future<void> _confirmRemove(
    BuildContext context,
    ActiveWorkoutController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitar ejercicio'),
        content: Text('¿Quitar "${exercise.nombre}" de la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.removeExercise(index);
  }

  /// Formatea el rendimiento anterior de un set para la columna PREVIOUS.
  String _formatPrevious(PreviousSetPerformance? performance) {
    if (performance == null) return '—';
    final peso = performance.peso;
    final reps = performance.reps;
    if (peso == null && reps == null) return '—';
    if (peso != null && reps != null) return '${_weight(peso)} kg × $reps';
    if (peso != null) return '${_weight(peso)} kg';
    return '$reps reps';
  }

  /// Peso a texto: sin decimales si es entero.
  String _weight(double peso) {
    if (peso == peso.roundToDouble()) return peso.toStringAsFixed(0);
    return peso.toString();
  }
}

/// Cabecera de columnas de la tabla de sets.
class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.textSecondary,
        );

    Widget cell(String label, {required int flex, double? width}) {
      final text = Text(label, textAlign: TextAlign.center, style: style);
      if (width != null) return SizedBox(width: width, child: text);
      return Expanded(flex: flex, child: text);
    }

    return Row(
      children: [
        cell('SET', flex: 0, width: 28),
        cell('PREVIOUS', flex: 3),
        const SizedBox(width: AppSpacing.xs),
        cell('KG', flex: 2),
        const SizedBox(width: AppSpacing.xs),
        cell('REPS', flex: 2),
        // Hueco del icono de completado (alinea con las filas).
        const SizedBox(width: 48),
      ],
    );
  }
}
