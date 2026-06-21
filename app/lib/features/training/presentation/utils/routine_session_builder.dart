import '../../domain/entities/active_exercise.dart';
import '../../domain/entities/active_set.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_exercise_item.dart';

/// Funciones puras para trabajar con los items de una rutina: convertir una
/// rutina en los ejercicios precargados de una sesión activa, y reordenar items.
/// Sin Flutter ni Supabase, para poder testearlas de forma aislada.

/// Convierte una [routine] en la lista de [ActiveExercise] con la que se precarga
/// la sesión activa: por cada item genera un ejercicio (snapshot de nombre/grupo,
/// `exerciseId`, `orden` secuencial 1..n) con `seriesObjetivo` sets vacíos
/// (`reps`/`peso` null, `completado` false, `numSet` 1..n), respetando el orden de
/// la rutina.
///
/// [nextSetUid] inyecta la identidad de cliente de cada set (el controller pasa su
/// secuencia real; en tests basta un contador). Así la función es pura y a la vez
/// los uids quedan únicos dentro de la sesión.
List<ActiveExercise> routineToActiveExercises(
  Routine routine,
  int Function() nextSetUid,
) {
  final exercises = <ActiveExercise>[];
  for (var i = 0; i < routine.items.length; i++) {
    final item = routine.items[i];
    final sets = <ActiveSet>[
      for (var s = 0; s < item.seriesObjetivo; s++)
        ActiveSet(uid: nextSetUid(), numSet: s + 1),
    ];
    exercises.add(
      ActiveExercise(
        exerciseId: item.exerciseId ?? 0,
        nombre: item.nombreEjercicio,
        grupoMuscular: item.grupoMuscular,
        orden: i + 1,
        sets: sets,
      ),
    );
  }
  return exercises;
}

/// Mueve el item en [from] una posición arriba ([direction] == -1) o abajo
/// ([direction] == 1) y renumera el `orden` (1..n) de toda la lista. Si el
/// movimiento sale de rango (primero hacia arriba / último hacia abajo) o los
/// índices son inválidos, devuelve la lista renumerada sin cambios de posición.
List<RoutineExerciseItem> reorderRoutineItems(
  List<RoutineExerciseItem> items,
  int from,
  int direction,
) {
  final result = [...items];
  final to = from + direction;
  if (from >= 0 && from < result.length && to >= 0 && to < result.length) {
    final moved = result.removeAt(from);
    result.insert(to, moved);
  }
  return [
    for (var i = 0; i < result.length; i++) result[i].copyWith(orden: i + 1),
  ];
}
