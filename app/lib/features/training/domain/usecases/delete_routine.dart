import '../repositories/routine_repository.dart';

/// Caso de uso: borrar una rutina (el cascade limpia sus `routine_exercises`).
class DeleteRoutine {
  const DeleteRoutine(this._repository);

  final RoutineRepository _repository;

  Future<void> call(int routineId) => _repository.deleteRoutine(routineId);
}
