import '../repositories/training_stats_repository.dart';
import '../utils/workout_streak.dart';

/// Caso de uso: racha actual de semanas consecutivas (≥3 entrenos) del usuario.
/// Obtiene las fechas de los workouts finalizados del repositorio y delega el
/// cálculo en la función pura [currentStreak].
class GetCurrentStreak {
  const GetCurrentStreak(this._repository);

  final TrainingStatsRepository _repository;

  Future<int> call() async {
    final dates = await _repository.fetchFinishedWorkoutDates();
    return currentStreak(dates);
  }
}
