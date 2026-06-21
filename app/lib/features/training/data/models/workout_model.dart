/// DTO de la tabla `workouts`: construye los payloads de INSERT (al iniciar) y de
/// UPDATE (al finalizar). No envía ids autogenerados.
///
/// No extiende ninguna entidad de dominio porque la sesión en memoria es
/// [ActiveWorkout] (con sus ejercicios y sets); aquí solo se serializa la fila de
/// cabecera de `workouts`.
abstract final class WorkoutModel {
  /// Payload para crear la sesión. `fecha` (default hoy), `finalizado` (default
  /// false) y `created_at` los rellena la BD; el entreno libre va sin
  /// `routine_id`.
  static Map<String, dynamic> toStartInsert(String userId, String nombre) {
    return {
      'user_id': userId,
      'nombre': nombre,
    };
  }

  /// Payload para cerrar la sesión: marca finalizado y guarda la duración.
  static Map<String, dynamic> toFinishUpdate(int duracionSegundos) {
    return {
      'finalizado': true,
      'duracion_s': duracionSegundos,
    };
  }
}
