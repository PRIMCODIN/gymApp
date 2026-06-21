import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/training_failure.dart';
import '../../domain/entities/active_exercise.dart';
import '../../domain/entities/active_set.dart';
import '../../domain/entities/active_workout.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/routine.dart';
import '../utils/routine_session_builder.dart';
import '../utils/workout_session_format.dart';
import 'workout_session_providers.dart';

/// Fase de la sesión de entreno. La UI la usa para decidir qué pintar (pantalla
/// de inicio, sesión activa, spinners de iniciar/finalizar).
enum ActiveSessionStatus {
  /// Sin sesión activa: pantalla de "Empezar entreno".
  idle,

  /// Creando el workout en la BD.
  starting,

  /// Sesión en curso: se añaden ejercicios y sets en memoria.
  active,

  /// Guardando (finalizar) o descartando (cancelar) la sesión.
  finishing,
}

/// Estado inmutable de la sesión de entreno.
///
/// Combina [status] (fase async) + [workout] (estado en memoria que se edita en
/// vivo) + [errorMessage] (nunca se silencia un fallo). Como en
/// `MealEntryState`, `copyWith` NO arrastra el `errorMessage` anterior: se pone a
/// null salvo que se pase explícitamente.
class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.status,
    this.workout,
    this.errorMessage,
  });

  const ActiveWorkoutState.idle() : this(status: ActiveSessionStatus.idle);

  final ActiveSessionStatus status;

  /// Sesión en memoria (null mientras no hay una activa).
  final ActiveWorkout? workout;

  /// Mensaje de error legible en español (null = sin error).
  final String? errorMessage;

  bool get isStarting => status == ActiveSessionStatus.starting;
  bool get isActive => status == ActiveSessionStatus.active;
  bool get isBusy =>
      status == ActiveSessionStatus.starting ||
      status == ActiveSessionStatus.finishing;

  ActiveWorkoutState copyWith({
    ActiveSessionStatus? status,
    ActiveWorkout? workout,
    String? errorMessage,
  }) {
    return ActiveWorkoutState(
      status: status ?? this.status,
      workout: workout ?? this.workout,
      errorMessage: errorMessage,
    );
  }
}

/// Mantiene la sesión de entreno en memoria y expone las acciones de edición y
/// las operaciones de BD (iniciar / finalizar / cancelar). Las ediciones de sets
/// y ejercicios son síncronas (solo memoria); el guardado masivo ocurre al
/// finalizar (ver decisiones de diseño de la fase).
class ActiveWorkoutController extends Notifier<ActiveWorkoutState> {
  @override
  ActiveWorkoutState build() => const ActiveWorkoutState.idle();

  /// Secuencia para la identidad de cliente de los sets ([ActiveSet.uid]).
  int _setUidSeq = 0;

  int _nextSetUid() => ++_setUidSeq;

  // --- Operaciones de BD ---

  /// Inicia una sesión libre: persiste el workout (`finalizado=false`) y pasa a
  /// estado activo con un workout vacío en memoria.
  Future<void> start() async {
    if (state.status != ActiveSessionStatus.idle) return;

    final now = DateTime.now();
    final nombre = _defaultName(now);
    state = const ActiveWorkoutState(status: ActiveSessionStatus.starting);

    try {
      final id = await ref.read(startWorkoutProvider).call(nombre);
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.active,
        workout: ActiveWorkout(
          id: id,
          nombre: nombre,
          fecha: DateTime(now.year, now.month, now.day),
          startedAt: now,
          exercises: const [],
        ),
      );
    } catch (error) {
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.idle,
        errorMessage: _message(error),
      );
    }
  }

  /// Inicia una sesión PRECARGADA desde una rutina: persiste el workout con su
  /// `routine_id` (trazabilidad) y precarga un ejercicio por cada item de la
  /// rutina, con `seriesObjetivo` sets vacíos en orden. A partir de aquí la
  /// sesión funciona igual que la libre (rellenar, PREVIOUS, finalizar): se
  /// reutiliza toda la mecánica, solo cambia el punto de entrada.
  Future<void> startFromRoutine(Routine routine) async {
    if (state.status != ActiveSessionStatus.idle) return;

    final now = DateTime.now();
    final nombre = routine.nombre;
    state = const ActiveWorkoutState(status: ActiveSessionStatus.starting);

    try {
      final id = await ref
          .read(startWorkoutProvider)
          .call(nombre, routineId: routine.id);
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.active,
        workout: ActiveWorkout(
          id: id,
          nombre: nombre,
          fecha: DateTime(now.year, now.month, now.day),
          startedAt: now,
          exercises: routineToActiveExercises(routine, _nextSetUid),
        ),
      );
    } catch (error) {
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.idle,
        errorMessage: _message(error),
      );
    }
  }

  /// Finaliza la sesión: calcula la duración, guarda todos los sets y marca el
  /// workout como finalizado. Al terminar, limpia el estado en memoria (idle).
  Future<void> finish() async {
    final workout = state.workout;
    if (workout == null || state.status != ActiveSessionStatus.active) return;

    final duracion = workoutDurationSeconds(workout.startedAt, DateTime.now());
    state = state.copyWith(status: ActiveSessionStatus.finishing);

    try {
      await ref.read(finishWorkoutProvider).call(workout, duracion);
      state = const ActiveWorkoutState.idle();
    } catch (error) {
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.active,
        workout: workout,
        errorMessage: _message(error),
      );
    }
  }

  /// Descarta la sesión: borra el workout iniciado y limpia el estado.
  Future<void> cancel() async {
    final workout = state.workout;
    if (workout == null || state.status != ActiveSessionStatus.active) return;

    state = state.copyWith(status: ActiveSessionStatus.finishing);

    try {
      await ref.read(cancelWorkoutProvider).call(workout.id);
      state = const ActiveWorkoutState.idle();
    } catch (error) {
      state = ActiveWorkoutState(
        status: ActiveSessionStatus.active,
        workout: workout,
        errorMessage: _message(error),
      );
    }
  }

  // --- Ediciones en memoria ---

  /// Renombra la sesión.
  void rename(String nombre) {
    final workout = state.workout;
    if (workout == null) return;
    state = state.copyWith(workout: workout.copyWith(nombre: nombre));
  }

  /// Añade un ejercicio (desde el selector) al final, con un set inicial vacío.
  void addExercise(Exercise exercise) {
    final workout = state.workout;
    if (workout == null) return;

    final nuevo = ActiveExercise(
      exerciseId: exercise.id,
      nombre: exercise.nombre,
      grupoMuscular: exercise.grupoMuscular,
      orden: workout.exercises.length + 1,
      sets: [ActiveSet(uid: _nextSetUid(), numSet: 1)],
    );
    state = state.copyWith(
      workout: workout.copyWith(exercises: [...workout.exercises, nuevo]),
    );
  }

  /// Añade un set a un ejercicio, precargando reps/peso del ÚLTIMO set del mismo
  /// ejercicio en esta sesión (conveniencia; editable).
  void addSet(int exerciseIndex) {
    _updateExercise(exerciseIndex, (exercise) {
      final last = exercise.sets.isNotEmpty ? exercise.sets.last : null;
      final nuevo = ActiveSet(
        uid: _nextSetUid(),
        numSet: exercise.sets.length + 1,
        reps: last?.reps,
        peso: last?.peso,
      );
      return exercise.copyWith(sets: [...exercise.sets, nuevo]);
    });
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

  /// Marca/desmarca un set como completado.
  void toggleCompletado(int exerciseIndex, int setIndex) {
    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(completado: !set.completado),
    );
  }

  /// Borra un set y renumera los `num_set` restantes (1, 2, 3...).
  void removeSet(int exerciseIndex, int setIndex) {
    _updateExercise(exerciseIndex, (exercise) {
      if (setIndex < 0 || setIndex >= exercise.sets.length) return exercise;
      final sets = [...exercise.sets]..removeAt(setIndex);
      final renumerados = [
        for (var i = 0; i < sets.length; i++) sets[i].copyWith(numSet: i + 1),
      ];
      return exercise.copyWith(sets: renumerados);
    });
  }

  /// Quita un ejercicio y renumera el `orden` de los restantes.
  void removeExercise(int exerciseIndex) {
    final workout = state.workout;
    if (workout == null) return;
    if (exerciseIndex < 0 || exerciseIndex >= workout.exercises.length) return;

    final exercises = [...workout.exercises]..removeAt(exerciseIndex);
    final renumerados = [
      for (var i = 0; i < exercises.length; i++)
        exercises[i].copyWith(orden: i + 1),
    ];
    state = state.copyWith(workout: workout.copyWith(exercises: renumerados));
  }

  /// Limpia el mensaje de error (tras mostrarlo en la UI).
  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith();
  }

  // --- Helpers privados ---

  void _updateExercise(
    int index,
    ActiveExercise Function(ActiveExercise) update,
  ) {
    final workout = state.workout;
    if (workout == null) return;
    if (index < 0 || index >= workout.exercises.length) return;

    final exercises = [...workout.exercises];
    exercises[index] = update(exercises[index]);
    state = state.copyWith(workout: workout.copyWith(exercises: exercises));
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex,
    ActiveSet Function(ActiveSet) update,
  ) {
    _updateExercise(exerciseIndex, (exercise) {
      if (setIndex < 0 || setIndex >= exercise.sets.length) return exercise;
      final sets = [...exercise.sets];
      sets[setIndex] = update(sets[setIndex]);
      return exercise.copyWith(sets: sets);
    });
  }

  /// Nombre por defecto de la sesión: "Entreno" + fecha corta (editable).
  String _defaultName(DateTime now) {
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    return 'Entreno $dd/$mm';
  }

  String _message(Object error) => mapTrainingError(error).message;
}

final activeWorkoutControllerProvider =
    NotifierProvider<ActiveWorkoutController, ActiveWorkoutState>(
  ActiveWorkoutController.new,
);
