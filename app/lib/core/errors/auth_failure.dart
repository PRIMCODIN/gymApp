import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de autenticación con un mensaje legible en español para la UI.
///
/// Centraliza la regla "nada de errores silenciosos" (`specs/conventions.md`):
/// cualquier error de Supabase se traduce aquí a un texto que el usuario entiende.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Traduce un error cualquiera (típicamente [AuthException]) a un [AuthFailure]
/// con mensaje en español. Si no se reconoce, devuelve un mensaje genérico pero
/// nunca lo silencia.
AuthFailure mapAuthError(Object error) {
  if (error is AuthFailure) return error;

  if (error is AuthException) {
    final code = error.code?.toLowerCase();
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return const AuthFailure('Email o contraseña incorrectos.');
    }
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('already registered') ||
        message.contains('user already registered')) {
      return const AuthFailure('Ese email ya está registrado.');
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return const AuthFailure(
        'Debes confirmar tu email antes de iniciar sesión.',
      );
    }
    if (code == 'over_email_send_rate_limit' ||
        code == 'over_request_rate_limit' ||
        message.contains('rate limit') ||
        message.contains('for security purposes')) {
      return const AuthFailure(
        'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.',
      );
    }
    if (code == 'weak_password' || message.contains('password')) {
      return const AuthFailure(
        'La contraseña no es válida (mínimo 8 caracteres).',
      );
    }
    if (code == 'validation_failed' ||
        message.contains('unable to validate email')) {
      return const AuthFailure('El email no tiene un formato válido.');
    }
    // AuthException reconocida pero sin caso específico: mostramos su mensaje.
    return AuthFailure('Error de autenticación: ${error.message}');
  }

  return const AuthFailure(
    'Ha ocurrido un error inesperado. Inténtalo de nuevo.',
  );
}
