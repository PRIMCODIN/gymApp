import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import 'auth_providers.dart';

/// Desenlace de una acción del formulario que la UI necesita distinguir más allá
/// de loading/error.
enum AuthFormStatus {
  /// Sin acción pendiente, o login correcto (la navegación la hace el `AuthGate`).
  idle,

  /// Registro correcto pero el usuario debe confirmar su email antes de entrar.
  emailConfirmationRequired,
}

/// Controla las acciones del formulario de login/registro.
///
/// Expone su estado como `AsyncValue<AuthFormStatus>`: la UI lee `isLoading` para
/// el indicador de carga, `hasError` para el mensaje legible, y el valor de
/// `AuthFormStatus` para saber si tras un registro hay que pedir confirmación de
/// email. El cambio de pantalla tras un login correcto NO se gestiona aquí: lo
/// hace el `AuthGate` reaccionando a `authStateProvider`.
class LoginController extends AsyncNotifier<AuthFormStatus> {
  @override
  Future<AuthFormStatus> build() async {
    // Sin acción pendiente al arrancar.
    return AuthFormStatus.idle;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      await ref.read(signInProvider).call(
            email: email.trim(),
            password: password,
          );
      // El AuthGate cambia de pantalla al detectar la nueva sesión.
      return AuthFormStatus.idle;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _run(() async {
      final result = await ref.read(signUpProvider).call(
            email: email.trim(),
            password: password,
            name: name.trim(),
          );
      return result.needsEmailConfirmation
          ? AuthFormStatus.emailConfirmationRequired
          : AuthFormStatus.idle;
    });
  }

  /// Ejecuta una acción de auth gestionando loading/error de forma uniforme.
  /// Captura cualquier error y lo normaliza a [AuthFailure] (mensaje en español).
  Future<void> _run(Future<AuthFormStatus> Function() action) async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await action());
    } catch (error, stackTrace) {
      state = AsyncError(mapAuthError(error), stackTrace);
    }
  }
}

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, AuthFormStatus>(LoginController.new);
