import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: observar el estado de sesión de forma reactiva.
///
/// Emite el [AuthUser] actual en cada cambio (login/logout) y `null` cuando no
/// hay sesión. Es la fuente del cambio de pantalla reactivo del `AuthGate`.
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}
