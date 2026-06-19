import '../../domain/repositories/calorie_goal_repository.dart';
import '../datasources/calorie_goal_supabase_datasource.dart';

/// Implementación del contrato de objetivo de calorías: lee de Supabase.
class CalorieGoalRepositoryImpl implements CalorieGoalRepository {
  const CalorieGoalRepositoryImpl(this._datasource);

  final CalorieGoalSupabaseDataSource _datasource;

  @override
  Future<int> fetchDailyGoal() => _datasource.fetchDailyGoal();
}
