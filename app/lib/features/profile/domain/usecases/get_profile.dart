import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Caso de uso: leer el perfil del usuario en sesión.
class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call() => _repository.fetchProfile();
}
