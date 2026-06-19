import '../../domain/entities/food_log.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../datasources/food_log_supabase_datasource.dart';
import '../models/food_log_model.dart';

/// Implementación del contrato de guardado y lectura: opera sobre Supabase.
class FoodLogRepositoryImpl implements FoodLogRepository {
  const FoodLogRepositoryImpl(this._datasource);

  final FoodLogSupabaseDataSource _datasource;

  @override
  Future<void> save(FoodLog log) {
    return _datasource.insert(FoodLogModel.fromEntity(log));
  }

  @override
  Future<List<FoodLogEntry>> fetchByDate(DateTime date) =>
      _datasource.fetchByDate(date);

  @override
  Future<void> update(int id, FoodLog log) {
    return _datasource.update(id, FoodLogModel.fromEntity(log));
  }

  @override
  Future<void> delete(int id) => _datasource.delete(id);
}
