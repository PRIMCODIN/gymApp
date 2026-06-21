import '../entities/previous_set_performance.dart';
import '../repositories/workout_repository.dart';

/// Caso de uso: obtener el rendimiento anterior (columna PREVIOUS) de un
/// ejercicio, set a set, desde la última sesión finalizada del usuario.
class FetchPreviousPerformance {
  const FetchPreviousPerformance(this._repository);

  final WorkoutRepository _repository;

  Future<List<PreviousSetPerformance>> call(int exerciseId) =>
      _repository.fetchPreviousPerformance(exerciseId);
}
