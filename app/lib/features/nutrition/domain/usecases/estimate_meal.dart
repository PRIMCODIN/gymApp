import '../entities/nutrition_estimate.dart';
import '../repositories/meal_estimation_repository.dart';

/// Caso de uso: estimar kcal + macros de una comida descrita por texto.
/// Llama a n8n a través del repositorio de estimación.
class EstimateMeal {
  const EstimateMeal(this._repository);

  final MealEstimationRepository _repository;

  Future<NutritionEstimate> call({required String descripcion}) {
    return _repository.estimate(descripcion: descripcion);
  }
}
