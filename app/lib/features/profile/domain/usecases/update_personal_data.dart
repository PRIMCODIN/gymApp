import '../entities/personal_data.dart';
import '../repositories/profile_repository.dart';

/// Caso de uso: actualizar los datos antropométricos del usuario.
class UpdatePersonalData {
  const UpdatePersonalData(this._repository);

  final ProfileRepository _repository;

  Future<void> call(PersonalData data) => _repository.updatePersonalData(data);
}
