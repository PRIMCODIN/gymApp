import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_exercise_item.dart';
import 'routine_exercise_model.dart';

/// DTO de la tabla `routines`: lee filas (cabecera + items embebidos) y construye
/// el payload de inserción de la cabecera. No envía ids autogenerados.
abstract final class RoutineModel {
  /// Construye una [Routine] desde una fila de `routines`. Si la fila trae
  /// `routine_exercises` embebidos (select con join), los mapea y ordena por
  /// `orden`; si no, la rutina queda sin items (solo cabecera).
  static Routine fromRow(Map<String, dynamic> row) {
    final rawItems = row['routine_exercises'];
    final items = rawItems is List
        ? rawItems
            .cast<Map<String, dynamic>>()
            .map(RoutineExerciseModel.fromRow)
            .toList()
        : <RoutineExerciseItem>[];
    items.sort((a, b) => a.orden.compareTo(b.orden));

    return Routine(
      id: (row['id'] as num).toInt(),
      nombre: (row['nombre'] as String?) ?? '',
      items: items,
    );
  }

  /// Payload para crear la cabecera. Fuerza `user_id` al usuario en sesión; no
  /// envía `id` ni `created_at` (los pone la BD).
  static Map<String, dynamic> toInsert(String userId, String nombre) {
    return {
      'user_id': userId,
      'nombre': nombre,
    };
  }
}
