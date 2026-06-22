import '../repositories/profile_repository.dart';

/// Caso de uso: actualizar el objetivo de kcal diario del usuario.
class UpdateCalorieGoal {
  const UpdateCalorieGoal(this._repository);

  final ProfileRepository _repository;

  Future<void> call(int goal) => _repository.updateCalorieGoal(goal);
}
