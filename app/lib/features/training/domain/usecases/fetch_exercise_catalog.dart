import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

/// Caso de uso: obtener el catálogo de ejercicios visibles (globales + propios),
/// ordenado por nombre. Lectura directa a Supabase (ver `specs/architecture.md`).
class FetchExerciseCatalog {
  const FetchExerciseCatalog(this._repository);

  final ExerciseRepository _repository;

  Future<List<Exercise>> call() => _repository.fetchCatalog();
}
