import '../entities/routine.dart';
import '../repositories/routine_repository.dart';

/// Caso de uso: cargar una rutina con sus items completos (para editar/empezar).
class FetchRoutineDetail {
  const FetchRoutineDetail(this._repository);

  final RoutineRepository _repository;

  Future<Routine> call(int routineId) =>
      _repository.fetchRoutineDetail(routineId);
}
