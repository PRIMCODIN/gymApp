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

  /// Copia con campos puntuales cambiados (para la edición en memoria de D2).
  WorkoutDetail copyWith({
    int? id,
    String? nombre,
    DateTime? fecha,
    int? duracionS,
    List<WorkoutDetailExercise>? exercises,
  }) {
    return WorkoutDetail(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      duracionS: duracionS ?? this.duracionS,
      exercises: exercises ?? this.exercises,
    );
  }
}

/// Un ejercicio dentro del detalle: snapshot de nombre y grupo muscular (tal como
/// se guardó al finalizar) más sus sets ordenados por `num_set`.
class WorkoutDetailExercise {
  const WorkoutDetailExercise({
    required this.nombreEjercicio,
    required this.grupoMuscular,
    required this.orden,
    required this.sets,
    this.exerciseId,
  });

  /// Id del ejercicio en el catálogo (`null` si era un ejercicio libre). Se
  /// conserva al reescribir los sets en la edición: el PREVIOUS de futuras
  /// sesiones depende de él.
  final int? exerciseId;

  final String nombreEjercicio;

  /// Clave de grupo muscular (se muestra vía `muscleGroupLabel`, nunca cruda).
  final String grupoMuscular;

  final int orden;

  final List<WorkoutDetailSet> sets;

  /// Copia con campos puntuales cambiados (preserva el resto).
  WorkoutDetailExercise copyWith({
    int? exerciseId,
    String? nombreEjercicio,
    String? grupoMuscular,
    int? orden,
    List<WorkoutDetailSet>? sets,
  }) {
    return WorkoutDetailExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      nombreEjercicio: nombreEjercicio ?? this.nombreEjercicio,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      orden: orden ?? this.orden,
      sets: sets ?? this.sets,
    );
  }
}

/// Un set registrado: número, reps y peso (pueden ser null si quedaron a medias) y
/// si se marcó como completado.
class WorkoutDetailSet {
  const WorkoutDetailSet({
    required this.numSet,
    required this.completado,
    this.reps,
    this.peso,
    this.rpe,
    this.uid,
  });

  final int numSet;
  final int? reps;
  final double? peso;
  final bool completado;

  /// RPE registrado (`null` si no se anotó). No se edita en D2, pero se conserva
  /// al reescribir los sets.
  final double? rpe;

  /// Identidad estable de cliente (NO se persiste; `null` en lectura). Se siembra
  /// al entrar en edición para dar una `Key` fija a cada fila editable: así los
  /// `TextField` de KG/REPS conservan su estado al editar otros sets o al
  /// renumerar tras un borrado. Mismo papel que `ActiveSet.uid`.
  final int? uid;

  /// Copia con campos puntuales cambiados (preserva [uid]). Para `reps`/`peso` se
  /// usan flags explícitos ([resetReps]/[resetPeso]) porque son nullables y un
  /// `null` en el parámetro no puede distinguir "no cambiar" de "poner a null".
  WorkoutDetailSet copyWith({
    int? numSet,
    int? reps,
    double? peso,
    bool? completado,
    double? rpe,
    int? uid,
    bool resetReps = false,
    bool resetPeso = false,
  }) {
    return WorkoutDetailSet(
      numSet: numSet ?? this.numSet,
      reps: resetReps ? null : (reps ?? this.reps),
      peso: resetPeso ? null : (peso ?? this.peso),
      completado: completado ?? this.completado,
      rpe: rpe ?? this.rpe,
      uid: uid ?? this.uid,
    );
  }
}
