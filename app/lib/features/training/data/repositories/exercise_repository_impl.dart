import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_supabase_datasource.dart';

/// Implementación del contrato del catálogo: opera sobre Supabase a través del
/// datasource.
class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl(this._datasource);

  final ExerciseSupabaseDataSource _datasource;

  @override
  Future<List<Exercise>> fetchCatalog() => _datasource.fetchCatalog();

  @override
  Future<Exercise> createCustom(String nombre, String grupoMuscular) =>
      _datasource.insertCustom(nombre, grupoMuscular);
}
