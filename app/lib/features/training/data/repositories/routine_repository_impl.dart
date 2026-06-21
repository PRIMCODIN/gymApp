import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_exercise_item.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/routine_supabase_datasource.dart';

/// Implementación del contrato de rutinas: delega en el datasource de Supabase.
class RoutineRepositoryImpl implements RoutineRepository {
  const RoutineRepositoryImpl(this._datasource);

  final RoutineSupabaseDataSource _datasource;

  @override
  Future<List<Routine>> fetchRoutines() => _datasource.fetchRoutines();

  @override
  Future<Routine> fetchRoutineDetail(int routineId) =>
      _datasource.fetchRoutineDetail(routineId);

  @override
  Future<int> createRoutine(String nombre, List<RoutineExerciseItem> items) =>
      _datasource.createRoutine(nombre, items);

  @override
  Future<void> updateRoutine(
    int routineId,
    String nombre,
    List<RoutineExerciseItem> items,
  ) =>
      _datasource.updateRoutine(routineId, nombre, items);

  @override
  Future<void> deleteRoutine(int routineId) =>
      _datasource.deleteRoutine(routineId);
}
