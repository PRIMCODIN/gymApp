import '../repositories/auth_repository.dart';

/// Caso de uso: enviar un email de recuperación de contraseña.
class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.sendPasswordReset(email: email);
  }
}
