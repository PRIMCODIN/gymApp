import '../repositories/food_log_repository.dart';

/// Caso de uso: borrar una comida ya registrada, identificada por su `id`.
/// Escritura directa a Supabase.
class DeleteFoodLog {
  const DeleteFoodLog(this._repository);

  final FoodLogRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
