import '../entities/food_log_entry.dart';
import '../repositories/food_log_repository.dart';

/// Caso de uso: obtener las comidas registradas el día [date] por el usuario en
/// sesión, más reciente primero. Lectura directa a Supabase (ver
/// `specs/architecture.md`).
class FetchFoodLogsByDate {
  const FetchFoodLogsByDate(this._repository);

  final FoodLogRepository _repository;

  Future<List<FoodLogEntry>> call(DateTime date) =>
      _repository.fetchByDate(date);
}
