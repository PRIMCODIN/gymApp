import '../entities/nutrition_estimate.dart';

/// Contrato para estimar la nutrición de una comida a partir de su descripción.
///
/// La implementación vive en data y delega en n8n (POST al webhook). El dominio
/// no sabe nada de HTTP ni de n8n: solo pide una estimación.
abstract class MealEstimationRepository {
  Future<NutritionEstimate> estimate({required String descripcion});
}
