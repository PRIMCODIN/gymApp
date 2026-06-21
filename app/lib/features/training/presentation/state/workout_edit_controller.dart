import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/training_failure.dart';
import '../../data/workout_edit_ops.dart';
import '../../domain/entities/workout_detail.dart';
import 'workout_history_providers.dart';

/// Fase del modo edición del detalle de un workout.
enum WorkoutEditStatus {
  /// Editando en memoria (o sin sesión de edición si `workout == null`).
  editing,

  /// Guardando los cambios en la BD.
  saving,
}

/// Estado del modo edición. `workout == null` significa "no se está editando"
/// (la pantalla muestra el detalle en solo lectura). Como en `ActiveWorkoutState`,
/// `copyWith` NO arrastra el `errorMessage` anterior: se pone a null salvo que se
/// pase explícitamente.
class WorkoutEditState {
  const WorkoutEditState({
    required this.status,
    this.workout,
    this.errorMessage,
    this.dirty = false,
  });

  const WorkoutEditState.idle() : this(status: WorkoutEditStatus.editing);

  final WorkoutEditStatus status;

  /// Copia en memoria del workout en edición (null = no se está editando).
  final WorkoutDetail? workout;

  /// Mensaje de error legible en español (null = sin error).
  final String? errorMessage;

  /// Hubo cambios desde que se entró en edición (para confirmar el descarte).
  final bool dirty;

  bool get isEditing => workout != null;
  bool get isSaving => status == WorkoutEditStatus.saving;

  WorkoutEditState copyWith({
    WorkoutEditStatus? status,
    WorkoutDetail? workout,
    String? errorMessage,
    bool? dirty,
  }) {
    return WorkoutEditState(
      status: status ?? this.status,
      workout: workout ?? this.workout,
      errorMessage: errorMessage,
      dirty: dirty ?? this.dirty,
    );
  }
}

/// Mantiene la copia en memoria del workout en edición y expone las acciones de
/// edición fina (kg/reps, borrar set/ejercicio, nombre, fecha) y el guardado
/// reversible. Nada toca la BD hasta `save()`; `discard()` tira la copia. Las
/// ediciones son síncronas (solo memoria); el renumerado reutiliza las funciones
/// puras de `workout_edit_ops.dart`.
class WorkoutEditController extends Notifier<WorkoutEditState> {
  @override
  WorkoutEditState build() => const WorkoutEditState.idle();

  /// Entra en modo edición sobre una copia del [detail] cargado (con uids de
  /// cliente sembrados para las filas editables). Reinicia error y `dirty`.
  void enterEditMode(WorkoutDetail detail) {
    state = WorkoutEditState(
      status: WorkoutEditStatus.editing,
      workout: detail.copyWith(exercises: assignSetUids(detail.exercises)),
    );
  }

  /// Actualiza las reps de un set (null = campo vacío).
  void updateSetReps(int exerciseIndex, int setIndex, int? reps) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(reps: reps, resetReps: reps == null),
    );
  }

  /// Actualiza el peso de un set (null = campo vacío).
  void updateSetPeso(int exerciseIndex, int setIndex, double? peso) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(peso: peso, resetPeso: peso == null),
    );
  }

  /// Borra un set y renumera los `num_set` restantes (1, 2, 3...).
  void removeSet(int exerciseIndex, int setIndex) {
    _updateExercise(
      exerciseIndex,
      (exercise) => exercise.copyWith(
        sets: removeSetAndRenumber(exercise.sets, setIndex),
      ),
    );
  }

  /// Quita un ejercicio entero y renumera el `orden` de los restantes.
  void removeExercise(int exerciseIndex) {
    final workout = state.workout;
    if (workout == null) return;
    state = state.copyWith(
      workout: workout.copyWith(
        exercises: removeExerciseAndRenumber(workout.exercises, exerciseIndex),
      ),
      dirty: true,
    );
  }

  /// Renombra el workout.
  void renameWorkout(String nombre) {
    final workout = state.workout;
    if (workout == null) return;
    state = state.copyWith(
      workout: workout.copyWith(nombre: nombre),
      dirty: true,
    );
  }

  /// Cambia la fecha del workout (local, sin componente horario).
  void changeDate(DateTime fecha) {
    final workout = state.workout;
    if (workout == null) return;
    state = state.copyWith(
      workout: workout.copyWith(
        fecha: DateTime(fecha.year, fecha.month, fecha.day),
      ),
      dirty: true,
    );
  }

  /// Persiste la edición (cabecera + reemplazo de sets). En éxito invalida los
  /// providers afectados y sale a solo lectura; en error mantiene el modo edición
  /// y expone el mensaje.
  Future<void> save() async {
    final workout = state.workout;
    if (workout == null || state.status == WorkoutEditStatus.saving) return;

    state = state.copyWith(status: WorkoutEditStatus.saving);

    try {
      await ref.read(saveWorkoutEditsProvider).call(
            workout.id,
            workout.nombre,
            workout.fecha,
            workout.exercises,
          );
      // Refresca el detalle, la lista del día y los marcadores del mes (la fecha
      // pudo cambiar de día y el volumen pudo variar).
      ref.invalidate(workoutDetailProvider);
      ref.invalidate(workoutsForDayProvider);
      ref.invalidate(workoutDatesForMonthProvider);
      state = const WorkoutEditState.idle();
    } catch (error) {
      state = WorkoutEditState(
        status: WorkoutEditStatus.editing,
        workout: workout,
        errorMessage: mapTrainingError(error).message,
        dirty: state.dirty,
      );
    }
  }

  /// Descarta la edición y vuelve a solo lectura (no toca la BD).
  void discard() {
    state = const WorkoutEditState.idle();
  }

  /// Limpia el mensaje de error (tras mostrarlo en la UI).
  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith();
  }

  // --- Helpers privados ---

  void _updateExercise(
    int index,
    WorkoutDetailExercise Function(WorkoutDetailExercise) update,
  ) {
    final workout = state.workout;
    if (workout == null) return;
    if (index < 0 || index >= workout.exercises.length) return;

    final exercises = [...workout.exercises];
    exercises[index] = update(exercises[index]);
    state = state.copyWith(
      workout: workout.copyWith(exercises: exercises),
      dirty: true,
    );
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex,
    WorkoutDetailSet Function(WorkoutDetailSet) update,
  ) {
    _updateExercise(exerciseIndex, (exercise) {
      if (setIndex < 0 || setIndex >= exercise.sets.length) return exercise;
      final sets = [...exercise.sets];
      sets[setIndex] = update(sets[setIndex]);
      return exercise.copyWith(sets: sets);
    });
  }
}

final workoutEditControllerProvider =
    NotifierProvider<WorkoutEditController, WorkoutEditState>(
  WorkoutEditController.new,
);
