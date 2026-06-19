import '../entities/food_log.dart';
import '../repositories/food_log_repository.dart';

/// Caso de uso: obtener las comidas registradas HOY por el usuario en sesión,
/// más reciente primero. Lectura directa a Supabase (ver `specs/architecture.md`).
class FetchTodayFoodLogs {
  const FetchTodayFoodLogs(this._repository);

  final FoodLogRepository _repository;

  Future<List<FoodLog>> call() => _repository.fetchToday();
}
