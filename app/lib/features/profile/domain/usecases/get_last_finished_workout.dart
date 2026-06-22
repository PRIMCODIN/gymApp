import '../entities/last_workout.dart';
import '../repositories/training_stats_repository.dart';

/// Caso de uso: último entreno finalizado del usuario en sesión (nombre + fecha),
/// o `null` si todavía no tiene ninguno.
class GetLastFinishedWorkout {
  const GetLastFinishedWorkout(this._repository);

  final TrainingStatsRepository _repository;

  Future<LastWorkout?> call() => _repository.fetchLastFinishedWorkout();
}
