import '../../domain/entities/auth_user.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación de [AuthRepository] apoyada en [AuthRemoteDataSource].
///
/// El datasource ya devuelve `AuthUserModel` (subtipo de [AuthUser]) y traduce
/// los errores a `AuthFailure`, así que aquí solo delegamos.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) {
    return _remote.signIn(email: email, password: password);
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _remote.signUp(email: email, password: password, name: name);
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _remote.sendPasswordReset(email: email);
  }

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Stream<AuthUser?> authStateChanges() => _remote.authStateChanges();

  @override
  AuthUser? get currentUser => _remote.currentUser;
}
