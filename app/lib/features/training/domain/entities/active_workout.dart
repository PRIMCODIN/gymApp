import 'active_exercise.dart';

/// La sesión de entreno ACTIVA, en memoria, mientras el usuario entrena.
///
/// El `workout` ya está persistido en la BD al iniciarse (de ahí [id] y [fecha]);
/// los ejercicios y sets viven aquí hasta que se finaliza. [startedAt] es la hora
/// local de inicio, usada para calcular la duración al finalizar. Diseñada para
/// que en el futuro pueda precargarse desde una rutina (no implementado aún).
/// Inmutable + [copyWith].
class ActiveWorkout {
  const ActiveWorkout({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.startedAt,
    required this.exercises,
  });

  /// Id del workout ya persistido en `workouts` (insertado al iniciar la sesión).
  final int id;

  final String nombre;

  /// Fecha de la sesión (la del workout en BD).
  final DateTime fecha;

  /// Hora local de inicio. Base para calcular la duración al finalizar.
  final DateTime startedAt;

  final List<ActiveExercise> exercises;

  ActiveWorkout copyWith({
    int? id,
    String? nombre,
    DateTime? fecha,
    DateTime? startedAt,
    List<ActiveExercise>? exercises,
  }) {
    return ActiveWorkout(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      startedAt: startedAt ?? this.startedAt,
      exercises: exercises ?? this.exercises,
    );
  }
}
