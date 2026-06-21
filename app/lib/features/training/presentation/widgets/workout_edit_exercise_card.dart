import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/workout_detail.dart';
import '../state/workout_edit_controller.dart';
import '../utils/muscle_groups.dart';
import 'workout_edit_set_row.dart';

/// Tarjeta editable de un ejercicio en el modo edición del detalle: cabecera
/// (nombre + grupo muscular, solo lectura) con acción de borrar el ejercicio
/// (confirmación) y sus sets como filas editables (kg/reps + borrar set).
class WorkoutEditExerciseCard extends ConsumerWidget {
  const WorkoutEditExerciseCard({
    super.key,
    required this.exerciseIndex,
    required this.exercise,
  });

  final int exerciseIndex;
  final WorkoutDetailExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final controller = ref.read(workoutEditControllerProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nombreEjercicio,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                onPressed: () => _confirmRemoveExercise(context, controller),
                tooltip: 'Borrar ejercicio',
                icon: Icon(Icons.delete_outline, color: palette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          for (var i = 0; i < exercise.sets.length; i++)
            WorkoutEditSetRow(
              key: ValueKey('edit-set-${exercise.sets[i].uid}'),
              numSet: exercise.sets[i].numSet,
              reps: exercise.sets[i].reps,
              peso: exercise.sets[i].peso,
              completado: exercise.sets[i].completado,
              onRepsChanged: (reps) =>
                  controller.updateSetReps(exerciseIndex, i, reps),
              onPesoChanged: (peso) =>
                  controller.updateSetPeso(exerciseIndex, i, peso),
              onRemove: () => controller.removeSet(exerciseIndex, i),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveExercise(
    BuildContext context,
    WorkoutEditController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar ejercicio'),
        content: Text(
          '¿Seguro que quieres borrar "${exercise.nombreEjercicio}" y sus sets?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.removeExercise(exerciseIndex);
    }
  }
}
