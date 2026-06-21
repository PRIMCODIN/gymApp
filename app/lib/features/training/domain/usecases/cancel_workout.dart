import '../repositories/workout_repository.dart';

/// Caso de uso: descartar una sesión iniciada. Borra el `workout` (el cascade
/// limpia sus sets).
class CancelWorkout {
  const CancelWorkout(this._repository);

  final WorkoutRepository _repository;

  Future<void> call(int workoutId) => _repository.cancelWorkout(workoutId);
}
