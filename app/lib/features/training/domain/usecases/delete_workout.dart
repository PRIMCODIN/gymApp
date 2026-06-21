import '../repositories/workout_history_repository.dart';

/// Caso de uso: borrar un workout entero (cascade limpia sus sets).
class DeleteWorkout {
  const DeleteWorkout(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<void> call(int workoutId) => _repository.deleteWorkout(workoutId);
}
