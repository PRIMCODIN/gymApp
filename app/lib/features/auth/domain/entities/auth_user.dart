/// Usuario autenticado, modelo de negocio puro.
///
/// Capa domain: Dart puro, sin dependencias de Flutter ni Supabase
/// (ver `specs/languageArchitecture.md`).
class AuthUser {
  const AuthUser({required this.id, required this.email});

  /// Identificador del usuario (`auth.users.id`).
  final String id;

  /// Email del usuario. Puede ser nulo en flujos sin email (no usado en el MVP).
  final String? email;
}
