import '../../domain/entities/workout_detail.dart';
import '../../domain/entities/workout_summary.dart';
import '../../domain/repositories/workout_history_repository.dart';
import '../datasources/workout_history_supabase_datasource.dart';

/// Implementación del repositorio del historial: delega 1:1 en la datasource de
/// Supabase (mismo patrón que `WorkoutRepositoryImpl`).
class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  const WorkoutHistoryRepositoryImpl(this._datasource);

  final WorkoutHistorySupabaseDataSource _datasource;

  @override
  Future<Set<DateTime>> fetchWorkoutDatesForMonth(int year, int month) =>
      _datasource.fetchWorkoutDatesForMonth(year, month);

  @override
  Future<List<WorkoutSummary>> fetchWorkoutsForDay(DateTime day) =>
      _datasource.fetchWorkoutsForDay(day);

  @override
  Future<WorkoutDetail> fetchWorkoutDetail(int workoutId) =>
      _datasource.fetchWorkoutDetail(workoutId);

  @override
  Future<void> updateWorkout(
    int workoutId,
    String nombre,
    DateTime fecha,
    List<WorkoutDetailExercise> exercises,
  ) =>
      _datasource.updateWorkout(workoutId, nombre, fecha, exercises);

  @override
  Future<void> deleteWorkout(int workoutId) =>
      _datasource.deleteWorkout(workoutId);
}
