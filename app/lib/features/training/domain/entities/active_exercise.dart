import 'active_set.dart';

/// Un ejercicio DENTRO de la sesión activa (estado en memoria), con sus sets.
///
/// Guarda un SNAPSHOT del ejercicio del catálogo ([nombre], [grupoMuscular]) más
/// su [exerciseId]: así, al persistir en `workout_sets`, el histórico conserva lo
/// que se hizo aunque el ejercicio del catálogo se renombre o borre. Inmutable +
/// [copyWith] para encajar con el estado de Riverpod.
class ActiveExercise {
  const ActiveExercise({
    required this.exerciseId,
    required this.nombre,
    required this.grupoMuscular,
    required this.orden,
    required this.sets,
  });

  /// FK al catálogo (`exercises.id`). Da el match fiable para la columna PREVIOUS.
  final int exerciseId;

  /// Snapshot del nombre del ejercicio en el momento de añadirlo.
  final String nombre;

  /// Snapshot del grupo muscular del ejercicio.
  final String grupoMuscular;

  /// Posición del ejercicio dentro de la sesión (1 = primero...).
  final int orden;

  final List<ActiveSet> sets;

  ActiveExercise copyWith({
    int? exerciseId,
    String? nombre,
    String? grupoMuscular,
    int? orden,
    List<ActiveSet>? sets,
  }) {
    return ActiveExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      nombre: nombre ?? this.nombre,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      orden: orden ?? this.orden,
      sets: sets ?? this.sets,
    );
  }
}
