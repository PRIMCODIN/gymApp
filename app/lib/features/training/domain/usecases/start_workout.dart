import '../repositories/workout_repository.dart';

/// Caso de uso: iniciar una sesión de entreno libre. Crea el `workout`
/// (`finalizado=false`) en Supabase y devuelve su `id`.
class StartWorkout {
  const StartWorkout(this._repository);

  final WorkoutRepository _repository;

  Future<int> call(String nombre) => _repository.startWorkout(nombre);
}
