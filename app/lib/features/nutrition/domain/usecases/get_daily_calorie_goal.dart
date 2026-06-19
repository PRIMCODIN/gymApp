import '../repositories/calorie_goal_repository.dart';

/// Caso de uso: leer el objetivo de calorías diario del usuario (default 2000).
class GetDailyCalorieGoal {
  const GetDailyCalorieGoal(this._repository);

  final CalorieGoalRepository _repository;

  Future<int> call() => _repository.fetchDailyGoal();
}
