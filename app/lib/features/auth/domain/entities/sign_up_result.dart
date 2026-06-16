import 'auth_user.dart';

/// Resultado de un registro, modelo de negocio puro (capa domain).
///
/// Distingue dos desenlaces del signUp según la configuración de Supabase:
/// - Si la confirmación por email está activa, Supabase crea el usuario pero NO
///   abre sesión: el usuario debe confirmar su email antes de poder entrar.
///   En ese caso [needsEmailConfirmation] es `true`.
/// - Si está desactivada, el registro abre sesión directamente y
///   [needsEmailConfirmation] es `false`.
class SignUpResult {
  const SignUpResult({
    required this.user,
    required this.needsEmailConfirmation,
  });

  /// Usuario recién registrado.
  final AuthUser user;

  /// `true` si el usuario debe confirmar su email antes de poder iniciar sesión.
  final bool needsEmailConfirmation;
}
