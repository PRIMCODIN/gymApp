import '../entities/active_workout.dart';
import '../repositories/workout_repository.dart';

/// Caso de uso: finalizar la sesión. Persiste todos los sets y marca el
/// `workout` como finalizado con su duración en segundos.
class FinishWorkout {
  const FinishWorkout(this._repository);

  final WorkoutRepository _repository;

  Future<void> call(ActiveWorkout workout, int duracionSegundos) =>
      _repository.finishWorkout(workout, duracionSegundos);
}
