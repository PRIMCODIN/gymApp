import '../../domain/entities/active_workout.dart';
import '../../domain/entities/previous_set_performance.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_supabase_datasource.dart';

/// Implementación del contrato de la sesión: delega en el datasource de Supabase.
class WorkoutRepositoryImpl implements WorkoutRepository {
  const WorkoutRepositoryImpl(this._datasource);

  final WorkoutSupabaseDataSource _datasource;

  @override
  Future<int> startWorkout(String nombre, {int? routineId}) =>
      _datasource.startWorkout(nombre, routineId: routineId);

  @override
  Future<List<PreviousSetPerformance>> fetchPreviousPerformance(
    int exerciseId,
  ) =>
      _datasource.fetchPreviousPerformance(exerciseId);

  @override
  Future<void> finishWorkout(ActiveWorkout workout, int duracionSegundos) =>
      _datasource.finishWorkout(workout, duracionSegundos);

  @override
  Future<void> cancelWorkout(int workoutId) =>
      _datasource.cancelWorkout(workoutId);
}
