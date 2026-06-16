import '../repositories/auth_repository.dart';

/// Caso de uso: cerrar la sesión actual.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
