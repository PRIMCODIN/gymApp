import '../../domain/entities/food_log.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../datasources/food_log_supabase_datasource.dart';
import '../models/food_log_model.dart';

/// Implementación del contrato de guardado: persiste en Supabase.
class FoodLogRepositoryImpl implements FoodLogRepository {
  const FoodLogRepositoryImpl(this._datasource);

  final FoodLogSupabaseDataSource _datasource;

  @override
  Future<void> save(FoodLog log) {
    return _datasource.insert(FoodLogModel.fromEntity(log));
  }
}
