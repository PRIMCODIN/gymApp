import '../../domain/entities/active_exercise.dart';
import '../../domain/entities/active_set.dart';
import '../../domain/entities/previous_set_performance.dart';

/// DTO de la tabla `workout_sets`: construye el payload de INSERT de un set al
/// finalizar y lee filas para la columna PREVIOUS.
abstract final class WorkoutSetModel {
  /// Mapa para insertar un set en `workout_sets`. Toma el snapshot de nombre y
  /// grupo muscular del [exercise]; `reps`/`peso` pueden ir a null (sets a
  /// medias). El `id` lo pone la BD.
  static Map<String, dynamic> toInsert(
    int workoutId,
    ActiveExercise exercise,
    ActiveSet set,
  ) {
    return {
      'workout_id': workoutId,
      'exercise_id': exercise.exerciseId,
      'nombre_ejercicio': exercise.nombre,
      'grupo_muscular': exercise.grupoMuscular,
      'orden_ejercicio': exercise.orden,
      'num_set': set.numSet,
      'reps': set.reps,
      'peso': set.peso,
      'completado': set.completado,
    };
  }

  /// Lee de una fila de `workout_sets` el rendimiento de un set (para PREVIOUS).
  static PreviousSetPerformance previousFromRow(Map<String, dynamic> row) {
    return PreviousSetPerformance(
      numSet: (row['num_set'] as num).toInt(),
      reps: readInt(row['reps']),
      peso: readDouble(row['peso']),
    );
  }

  /// Lee un entero tolerando null y representación como texto.
  static int? readInt(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Lee un numérico (`numeric` puede venir como texto, incl. coma decimal).
  static double? readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }
}
