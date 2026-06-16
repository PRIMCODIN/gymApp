import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../domain/entities/sign_up_result.dart';
import '../models/auth_user_model.dart';

/// Fuente de datos remota: envuelve las llamadas a `supabase.auth`.
///
/// Traduce cualquier error a [AuthFailure] (vía `mapAuthError`) para que las
/// capas superiores no manejen excepciones de Supabase directamente.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión. Inténtalo de nuevo.');
      }
      return AuthUserModel.fromSupabaseUser(user);
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        // El trigger `handle_new_user()` lee `nombre` de los metadatos para
        // rellenar la fila de `profiles` (ver `specs/database.md`).
        data: {'nombre': name.trim()},
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo completar el registro.');
      }
      // Con la confirmación por email activa, Supabase crea el usuario pero no
      // abre sesión (`session == null`) hasta que el email se confirma.
      return SignUpResult(
        user: AuthUserModel.fromSupabaseUser(user),
        needsEmailConfirmation: response.session == null,
      );
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  /// Emite el usuario actual en cada cambio de estado de auth, o `null` si no
  /// hay sesión.
  Stream<AuthUserModel?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user == null ? null : AuthUserModel.fromSupabaseUser(user);
    });
  }

  AuthUserModel? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabaseUser(user);
  }
}
