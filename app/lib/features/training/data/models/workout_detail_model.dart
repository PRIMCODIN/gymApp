import '../../domain/entities/workout_detail.dart';
import '../workout_stats.dart';
import 'workout_summary_model.dart' show parseLocalDate;

/// DTO de lectura: construye un [WorkoutDetail] desde la fila de cabecera de
/// `workouts` y sus filas de `workout_sets`, agrupando con la función pura
/// `groupSetsIntoExercises`.
abstract final class WorkoutDetailModel {
  static WorkoutDetail fromRows(
    Map<String, dynamic> workoutRow,
    List<Map<String, dynamic>> setRows,
  ) {
    return WorkoutDetail(
      id: (workoutRow['id'] as num).toInt(),
      nombre: (workoutRow['nombre'] as String?) ?? '',
      fecha: parseLocalDate(workoutRow['fecha']),
      duracionS: _readInt(workoutRow['duracion_s']),
      exercises: groupSetsIntoExercises(setRows),
    );
  }

  /// Aplana el estado editado (ejercicios -> sets) en filas de INSERT para
  /// `workout_sets`, preservando todos los snapshots (`exercise_id`,
  /// `nombre_ejercicio`, `grupo_muscular`) y `completado`/`rpe`. Se asume que
  /// `orden`/`num_set` ya vienen renumerados. El `id` lo pone la BD.
  static List<Map<String, dynamic>> toInsertRows(
    int workoutId,
    List<WorkoutDetailExercise> exercises,
  ) {
    return [
      for (final exercise in exercises)
        for (final set in exercise.sets)
          {
            'workout_id': workoutId,
            'exercise_id': exercise.exerciseId,
            'nombre_ejercicio': exercise.nombreEjercicio,
            'grupo_muscular': exercise.grupoMuscular,
            'orden_ejercicio': exercise.orden,
            'num_set': set.numSet,
            'reps': set.reps,
            'peso': set.peso,
            'completado': set.completado,
            'rpe': set.rpe,
          },
    ];
  }
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
