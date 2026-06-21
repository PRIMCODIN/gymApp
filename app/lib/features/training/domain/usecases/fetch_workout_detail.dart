import '../entities/workout_detail.dart';
import '../repositories/workout_history_repository.dart';

/// Caso de uso: detalle completo de un workout (ejercicios -> sets).
class FetchWorkoutDetail {
  const FetchWorkoutDetail(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<WorkoutDetail> call(int workoutId) =>
      _repository.fetchWorkoutDetail(workoutId);
}
