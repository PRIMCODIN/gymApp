import '../domain/entities/workout_detail.dart';

/// Operaciones puras de la edición del detalle de un workout (D2). Sin Flutter ni
/// Supabase para poder testearlas. Operan sobre las entidades de dominio ya
/// construidas y devuelven copias nuevas (inmutabilidad). Mismo precedente de
/// renumerado que `ActiveWorkoutController`, pero extraído como función pura.

/// Borra el set en [index] de [sets] y renumera los `num_set` restantes de forma
/// contigua (1, 2, 3...). Preserva el resto de campos de cada set (uid, rpe,
/// completado, reps, peso). Si [index] está fuera de rango devuelve la lista tal
/// cual (copia).
List<WorkoutDetailSet> removeSetAndRenumber(
  List<WorkoutDetailSet> sets,
  int index,
) {
  if (index < 0 || index >= sets.length) return [...sets];
  final restantes = [...sets]..removeAt(index);
  return [
    for (var i = 0; i < restantes.length; i++)
      restantes[i].copyWith(numSet: i + 1),
  ];
}

/// Borra el ejercicio en [index] de [exercises] y renumera el `orden` de los
/// restantes de forma contigua (1, 2, 3...). Si [index] está fuera de rango
/// devuelve la lista tal cual (copia).
List<WorkoutDetailExercise> removeExerciseAndRenumber(
  List<WorkoutDetailExercise> exercises,
  int index,
) {
  if (index < 0 || index >= exercises.length) return [...exercises];
  final restantes = [...exercises]..removeAt(index);
  return [
    for (var i = 0; i < restantes.length; i++)
      restantes[i].copyWith(orden: i + 1),
  ];
}

/// Siembra un `uid` de cliente único en cada set (necesario para dar `Key`
/// estable a las filas editables). Los `uid` se asignan secuencialmente partiendo
/// de 1. Devuelve la estructura de ejercicios con sus sets copiados.
List<WorkoutDetailExercise> assignSetUids(
  List<WorkoutDetailExercise> exercises,
) {
  var seq = 0;
  return [
    for (final exercise in exercises)
      exercise.copyWith(
        sets: [
          for (final set in exercise.sets) set.copyWith(uid: ++seq),
        ],
      ),
  ];
}
