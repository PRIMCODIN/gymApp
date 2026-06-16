// Ocultamos el `AuthUser` de Supabase para evitar la colisión con nuestra entity
// de dominio del mismo nombre. Solo necesitamos el tipo `User`.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';

/// DTO que adapta el `User` de Supabase a la entity de dominio [AuthUser].
class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.id, required super.email});

  /// Construye el modelo a partir del usuario de Supabase.
  factory AuthUserModel.fromSupabaseUser(User user) {
    return AuthUserModel(id: user.id, email: user.email);
  }
}
