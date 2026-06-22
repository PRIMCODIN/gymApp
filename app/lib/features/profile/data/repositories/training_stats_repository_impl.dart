import '../../domain/entities/last_workout.dart';
import '../../domain/repositories/training_stats_repository.dart';
import '../datasources/training_stats_supabase_datasource.dart';

/// Implementación del contrato de stats de entreno: delega en el datasource que
/// cuenta directo en Supabase.
class TrainingStatsRepositoryImpl implements TrainingStatsRepository {
  const TrainingStatsRepositoryImpl(this._datasource);

  final TrainingStatsSupabaseDataSource _datasource;

  @override
  Future<int> countFinishedWorkouts() => _datasource.countFinishedWorkouts();

  @override
  Future<int> countFinishedWorkoutsThisMonth() =>
      _datasource.countFinishedWorkoutsThisMonth();

  @override
  Future<List<DateTime>> fetchFinishedWorkoutDates() =>
      _datasource.fetchFinishedWorkoutDates();

  @override
  Future<LastWorkout?> fetchLastFinishedWorkout() =>
      _datasource.fetchLastFinishedWorkout();
}
