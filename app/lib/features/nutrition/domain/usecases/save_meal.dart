import '../entities/food_log.dart';
import '../repositories/food_log_repository.dart';

/// Caso de uso: guardar un registro de comida con los valores confirmados por el
/// usuario. Persiste directo en Supabase a través del repositorio.
class SaveMeal {
  const SaveMeal(this._repository);

  final FoodLogRepository _repository;

  Future<void> call(FoodLog log) {
    return _repository.save(log);
  }
}
