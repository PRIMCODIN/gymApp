import '../entities/routine_exercise_item.dart';
import '../repositories/routine_repository.dart';

/// Caso de uso: actualizar una rutina (cabecera + reemplazo de items).
class UpdateRoutine {
  const UpdateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<void> call(
    int routineId,
    String nombre,
    List<RoutineExerciseItem> items,
  ) =>
      _repository.updateRoutine(routineId, nombre, items);
}
