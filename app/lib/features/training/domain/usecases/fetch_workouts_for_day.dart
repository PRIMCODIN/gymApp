import '../entities/workout_summary.dart';
import '../repositories/workout_history_repository.dart';

/// Caso de uso: workouts finalizados de un día (con su resumen).
class FetchWorkoutsForDay {
  const FetchWorkoutsForDay(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<List<WorkoutSummary>> call(DateTime day) =>
      _repository.fetchWorkoutsForDay(day);
}
