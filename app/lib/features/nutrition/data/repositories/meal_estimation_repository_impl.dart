import '../../domain/entities/nutrition_estimate.dart';
import '../../domain/repositories/meal_estimation_repository.dart';
import '../datasources/n8n_meal_remote_datasource.dart';

/// Implementación del contrato de estimación: delega en n8n vía HTTP.
class MealEstimationRepositoryImpl implements MealEstimationRepository {
  const MealEstimationRepositoryImpl(this._remote);

  final N8nMealRemoteDataSource _remote;

  @override
  Future<NutritionEstimate> estimate({required String descripcion}) {
    return _remote.estimate(descripcion: descripcion);
  }
}
