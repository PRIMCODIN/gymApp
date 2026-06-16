import '../entities/auth_user.dart';
import '../entities/sign_up_result.dart';

/// Contrato de autenticación. La capa domain define QUÉ se necesita, no CÓMO se
/// obtiene (ver `specs/languageArchitecture.md`). La implementación vive en data.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña. Devuelve el usuario autenticado.
  /// Lanza `AuthFailure` si las credenciales son inválidas.
  Future<AuthUser> signIn({required String email, required String password});

  /// Registra un usuario nuevo con su [name] (se guarda en `profiles` vía el
  /// trigger de Supabase a partir de los metadatos). Devuelve un [SignUpResult]
  /// que indica si hace falta confirmar el email.
  /// Lanza `AuthFailure` si el email ya existe, etc.
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Envía un email de recuperación de contraseña a [email].
  /// Lanza `AuthFailure` si el envío falla (p. ej. rate limit).
  Future<void> sendPasswordReset({required String email});

  /// Cierra la sesión actual.
  Future<void> signOut();

  /// Emite el usuario actual cada vez que cambia el estado de sesión
  /// (login/logout). Emite `null` cuando no hay sesión activa.
  Stream<AuthUser?> authStateChanges();

  /// Usuario de la sesión actual, o `null` si no hay ninguna.
  AuthUser? get currentUser;
}
