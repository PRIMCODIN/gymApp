/// Detalle de lectura de un workout finalizado (solo lectura en D1).
///
/// Entidad pura de dominio, inmutable. Se diseña para poder ampliarse a edición
/// fina (nombre/fecha/sets) en D2 sin reestructurar: los sets ya guardan todos sus
/// campos editables. El volumen total NO se guarda como campo; se calcula en
/// presentation con la función pura `computeTotalVolume` (`data/workout_stats.dart`).
class WorkoutDetail {
  const WorkoutDetail({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.exercises,
    this.duracionS,
  });

  final int id;

  final String nombre;

  /// Fecha (local) del workout, sin componente horario.
  final DateTime fecha;

  /// Duración en segundos; `null` si no se registró.
  final int? duracionS;

  /// Ejercicios del workout, ordenados por `orden_ejercicio`.
  final List<WorkoutDetailExercise> exercises;

  int get numEjercicios => exercises.length;

  int get numSets =>
      exercises.fold(0, (total, exercise) => total + exercise.sets.length);
}

/// Un ejercicio dentro del detalle: snapshot de nombre y grupo muscular (tal como
/// se guardó al finalizar) más sus sets ordenados por `num_set`.
class WorkoutDetailExercise {
  const WorkoutDetailExercise({
    required this.nombreEjercicio,
    required this.grupoMuscular,
    required this.orden,
    required this.sets,
  });

  final String nombreEjercicio;

  /// Clave de grupo muscular (se muestra vía `muscleGroupLabel`, nunca cruda).
  final String grupoMuscular;

  final int orden;

  final List<WorkoutDetailSet> sets;
}

/// Un set registrado: número, reps y peso (pueden ser null si quedaron a medias) y
/// si se marcó como completado.
class WorkoutDetailSet {
  const WorkoutDetailSet({
    required this.numSet,
    required this.completado,
    this.reps,
    this.peso,
  });

  final int numSet;
  final int? reps;
  final double? peso;
  final bool completado;
}
