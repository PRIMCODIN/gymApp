import '../../domain/entities/routine_exercise_item.dart';

/// DTO de la tabla `routine_exercises`: lee filas a [RoutineExerciseItem] y
/// construye el payload de inserción de un item.
///
/// `grupo_muscular` NO es columna de `routine_exercises`: se resuelve del catálogo
/// vía el join embebido `exercises(grupo_muscular)`. Si el ejercicio se borró del
/// catálogo (`exercise_id` null o sin join), queda como string vacío y la UI
/// muestra solo el nombre snapshot.
abstract final class RoutineExerciseModel {
  /// Construye un [RoutineExerciseItem] desde una fila de `routine_exercises`.
  /// Toma el grupo muscular del `exercises` embebido si viene en el select.
  static RoutineExerciseItem fromRow(Map<String, dynamic> row) {
    final exercise = row['exercises'];
    final grupo = exercise is Map<String, dynamic>
        ? (exercise['grupo_muscular'] as String?) ?? ''
        : '';

    return RoutineExerciseItem(
      id: _readInt(row['id']),
      exerciseId: _readInt(row['exercise_id']),
      nombreEjercicio: (row['nombre_ejercicio'] as String?) ?? '',
      grupoMuscular: grupo,
      orden: _readInt(row['orden']) ?? 0,
      seriesObjetivo: _readInt(row['series_objetivo']) ?? 1,
      diaSemana: _readInt(row['dia_semana']),
    );
  }

  /// Payload para insertar un item de rutina. Toma el snapshot del nombre del
  /// ejercicio del propio item; el `id` lo pone la BD.
  static Map<String, dynamic> toInsert(int routineId, RoutineExerciseItem item) {
    return {
      'routine_id': routineId,
      'exercise_id': item.exerciseId,
      'nombre_ejercicio': item.nombreEjercicio,
      'orden': item.orden,
      'series_objetivo': item.seriesObjetivo,
      'dia_semana': item.diaSemana,
    };
  }

  /// Lee un entero tolerando null y representación como texto (numeric de Postgres
  /// puede llegar como String).
  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
