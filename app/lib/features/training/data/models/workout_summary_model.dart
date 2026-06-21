import '../../domain/entities/workout_summary.dart';
import '../workout_stats.dart';

/// DTO de lectura: construye un [WorkoutSummary] desde la fila de cabecera de
/// `workouts` y sus filas de `workout_sets`. Los conteos y el volumen se calculan
/// con las funciones puras de `workout_stats.dart`.
abstract final class WorkoutSummaryModel {
  static WorkoutSummary fromWorkoutAndSets(
    Map<String, dynamic> workoutRow,
    List<Map<String, dynamic>> setRows,
  ) {
    final exercises = groupSetsIntoExercises(setRows);
    final numSets = exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
    final volumen = computeTotalVolume(
      exercises.expand((exercise) => exercise.sets),
    );

    return WorkoutSummary(
      id: (workoutRow['id'] as num).toInt(),
      nombre: (workoutRow['nombre'] as String?) ?? '',
      fecha: parseLocalDate(workoutRow['fecha']),
      duracionS: _readInt(workoutRow['duracion_s']),
      numEjercicios: exercises.length,
      numSets: numSets,
      volumenTotal: volumen,
    );
  }
}

/// Parsea la columna `fecha` (tipo `date`, llega como `YYYY-MM-DD`) a un
/// [DateTime] local sin componente horario. Compartida por los DTOs del historial.
DateTime parseLocalDate(Object? value) {
  if (value is DateTime) {
    return DateTime(value.year, value.month, value.day);
  }
  final parsed = DateTime.parse(value as String);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
