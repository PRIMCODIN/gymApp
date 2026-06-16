import '../entities/sign_up_result.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: registrar un usuario nuevo con email, contraseña y nombre.
class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<SignUpResult> call({
    required String email,
    required String password,
    required String name,
  }) {
    return _repository.signUp(email: email, password: password, name: name);
  }
}
