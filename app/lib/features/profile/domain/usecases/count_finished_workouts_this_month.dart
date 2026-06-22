import '../repositories/training_stats_repository.dart';

/// Caso de uso: contar los workouts finalizados del usuario dentro del mes
/// natural actual.
class CountFinishedWorkoutsThisMonth {
  const CountFinishedWorkoutsThisMonth(this._repository);

  final TrainingStatsRepository _repository;

  Future<int> call() => _repository.countFinishedWorkoutsThisMonth();
}
