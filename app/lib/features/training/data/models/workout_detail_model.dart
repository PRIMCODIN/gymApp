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
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
