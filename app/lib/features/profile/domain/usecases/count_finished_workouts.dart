import '../repositories/training_stats_repository.dart';

/// Caso de uso: contar los workouts finalizados del usuario en sesión.
class CountFinishedWorkouts {
  const CountFinishedWorkouts(this._repository);

  final TrainingStatsRepository _repository;

  Future<int> call() => _repository.countFinishedWorkouts();
}
