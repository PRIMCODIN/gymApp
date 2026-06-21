import '../repositories/workout_repository.dart';

/// Caso de uso: iniciar una sesión de entreno. Crea el `workout`
/// (`finalizado=false`) en Supabase y devuelve su `id`. [routineId] traza el
/// origen cuando la sesión arranca desde una rutina (null en el entreno libre).
class StartWorkout {
  const StartWorkout(this._repository);

  final WorkoutRepository _repository;

  Future<int> call(String nombre, {int? routineId}) =>
      _repository.startWorkout(nombre, routineId: routineId);
}
