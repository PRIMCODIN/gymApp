import '../repositories/workout_history_repository.dart';

/// Caso de uso: días con workout finalizado en un mes (marcadores del calendario).
class FetchWorkoutDatesForMonth {
  const FetchWorkoutDatesForMonth(this._repository);

  final WorkoutHistoryRepository _repository;

  Future<Set<DateTime>> call(int year, int month) =>
      _repository.fetchWorkoutDatesForMonth(year, month);
}
