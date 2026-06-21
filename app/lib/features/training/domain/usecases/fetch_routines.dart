import '../entities/routine.dart';
import '../repositories/routine_repository.dart';

/// Caso de uso: listar las rutinas del usuario (cabeceras con sus items).
class FetchRoutines {
  const FetchRoutines(this._repository);

  final RoutineRepository _repository;

  Future<List<Routine>> call() => _repository.fetchRoutines();
}
