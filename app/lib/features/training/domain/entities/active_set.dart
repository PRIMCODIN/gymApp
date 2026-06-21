/// Un set de un ejercicio DENTRO de la sesión activa (estado en memoria).
///
/// No confundir con la fila de `workout_sets` de la BD: esto vive solo mientras
/// se entrena y se persiste al finalizar. Inmutable + [copyWith] para encajar con
/// el estado de Riverpod (cada edición produce una copia nueva). `reps` y `peso`
/// son nullables: el usuario puede dejar un set a medio rellenar.
class ActiveSet {
  const ActiveSet({
    required this.uid,
    required this.numSet,
    this.reps,
    this.peso,
    this.completado = false,
  });

  /// Identidad estable de cliente (NO se persiste). Permite a la UI dar una
  /// `Key` fija a cada fila de set: así los `TextField` de KG/REPS conservan su
  /// estado al editar otros sets o al renumerar tras un borrado.
  final int uid;

  /// Número de set dentro del ejercicio (1, 2, 3...).
  final int numSet;

  final int? reps;
  final double? peso;
  final bool completado;

  /// Copia con campos puntuales cambiados (preserva [uid]). Para `reps`/`peso` se
  /// usan flags explícitos ([resetReps]/[resetPeso]) porque son nullables y un
  /// `null` en el parámetro no puede distinguir "no cambiar" de "poner a null".
  ActiveSet copyWith({
    int? numSet,
    int? reps,
    double? peso,
    bool? completado,
    bool resetReps = false,
    bool resetPeso = false,
  }) {
    return ActiveSet(
      uid: uid,
      numSet: numSet ?? this.numSet,
      reps: resetReps ? null : (reps ?? this.reps),
      peso: resetPeso ? null : (peso ?? this.peso),
      completado: completado ?? this.completado,
    );
  }
}
