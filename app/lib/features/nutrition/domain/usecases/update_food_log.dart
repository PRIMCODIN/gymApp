import '../entities/food_log.dart';
import '../repositories/food_log_repository.dart';

/// Caso de uso: actualizar los campos editables (descripción + macros) de una
/// comida ya registrada, identificada por su `id`. Escritura directa a Supabase.
class UpdateFoodLog {
  const UpdateFoodLog(this._repository);

  final FoodLogRepository _repository;

  Future<void> call(int id, FoodLog log) => _repository.update(id, log);
}
