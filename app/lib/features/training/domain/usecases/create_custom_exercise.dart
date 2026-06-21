import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

/// Caso de uso: crear un ejercicio personalizado del usuario en sesión. Persiste
/// directo en Supabase a través del repositorio y devuelve el ejercicio creado.
class CreateCustomExercise {
  const CreateCustomExercise(this._repository);

  final ExerciseRepository _repository;

  Future<Exercise> call(String nombre, String grupoMuscular) =>
      _repository.createCustom(nombre, grupoMuscular);
}
