import '../entities/routine_exercise_item.dart';
import '../repositories/routine_repository.dart';

/// Caso de uso: crear una rutina (cabecera + items). Devuelve su `id`.
class CreateRoutine {
  const CreateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<int> call(String nombre, List<RoutineExerciseItem> items) =>
      _repository.createRoutine(nombre, items);
}
