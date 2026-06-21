/// Un ejercicio DENTRO de una rutina (plantilla), no de una sesión en curso.
///
/// Es una fila de `routine_exercises`. Guarda un SNAPSHOT del nombre del
/// ejercicio ([nombreEjercicio]) para que la rutina siga siendo legible aunque el
/// ejercicio del catálogo se renombre o borre. El [grupoMuscular] NO se persiste
/// en `routine_exercises`: se resuelve leyéndolo del catálogo (join por
/// [exerciseId]); si el ejercicio se borró del catálogo ([exerciseId] == null),
/// queda como string vacío y la UI muestra solo el nombre. Entidad pura de
/// dominio (sin Flutter ni Supabase). Inmutable + [copyWith].
class RoutineExerciseItem {
  const RoutineExerciseItem({
    this.id,
    this.exerciseId,
    required this.nombreEjercicio,
    this.grupoMuscular = '',
    required this.orden,
    required this.seriesObjetivo,
    this.diaSemana,
  });

  /// Id de la fila en `routine_exercises` (null mientras no se ha persistido).
  final int? id;

  /// FK al catálogo (`exercises.id`). `null` si el ejercicio se borró del catálogo.
  final int? exerciseId;

  /// Snapshot del nombre del ejercicio en el momento de añadirlo a la rutina.
  final String nombreEjercicio;

  /// Grupo muscular resuelto desde el catálogo (no se persiste aquí). Vacío si no
  /// se pudo resolver (ejercicio borrado del catálogo).
  final String grupoMuscular;

  /// Posición del ejercicio dentro de la rutina (1 = primero...).
  final int orden;

  /// Número de series objetivo de este ejercicio en la rutina.
  final int seriesObjetivo;

  /// Día de la semana (1 = lunes ... 7 = domingo). `null` = sin día asignado.
  final int? diaSemana;

  RoutineExerciseItem copyWith({
    int? id,
    int? exerciseId,
    String? nombreEjercicio,
    String? grupoMuscular,
    int? orden,
    int? seriesObjetivo,
    int? diaSemana,
  }) {
    return RoutineExerciseItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      nombreEjercicio: nombreEjercicio ?? this.nombreEjercicio,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      orden: orden ?? this.orden,
      seriesObjetivo: seriesObjetivo ?? this.seriesObjetivo,
      diaSemana: diaSemana ?? this.diaSemana,
    );
  }
}
