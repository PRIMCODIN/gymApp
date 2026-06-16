import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import 'auth_providers.dart';

/// Desenlace del envío del email de recuperación de contraseña.
enum PasswordResetStatus {
  /// Aún no se ha enviado nada (estado inicial).
  idle,

  /// El email de recuperación se ha enviado correctamente.
  sent,
}

/// Controla el flujo de "recuperar contraseña".
///
/// Estado como `AsyncValue<PasswordResetStatus>`:
/// - `isLoading` → enviando.
/// - `AsyncData(sent)` → enviado.
/// - `hasError` → error (mensaje en español vía [mapAuthError]).
class PasswordResetController extends AsyncNotifier<PasswordResetStatus> {
  @override
  Future<PasswordResetStatus> build() async {
    return PasswordResetStatus.idle;
  }

  Future<void> send({required String email}) async {
    state = const AsyncLoading();
    try {
      await ref.read(sendPasswordResetProvider).call(email: email.trim());
      state = const AsyncData(PasswordResetStatus.sent);
    } catch (error, stackTrace) {
      state = AsyncError(mapAuthError(error), stackTrace);
    }
  }
}

final passwordResetControllerProvider =
    AsyncNotifierProvider<PasswordResetController, PasswordResetStatus>(
  PasswordResetController.new,
);
