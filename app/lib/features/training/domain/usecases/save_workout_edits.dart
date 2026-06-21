import '../entities/workout_detail.dart';
import '../repositories/workout_history_repository.dart';

/// Caso de uso: guardar la edición de un workout pasado (cabecera + reemplazo de
/// sets en una sola operación). Espejo de `UpdateRoutine`.
class SaveWorkoutEdits {
  const SaveWorkoutEdits(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<void> call(
    int workoutId,
    String nombre,
    DateTime fecha,
    List<WorkoutDetailExercise> exercises,
  ) =>
      _repository.updateWorkout(workoutId, nombre, fecha, exercises);
}
