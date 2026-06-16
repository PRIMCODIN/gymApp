/// Acceso centralizado a la configuración del entorno.
///
/// Las claves SOLO viven en `app/env.json` y se inyectan en tiempo de compilación
/// con `--dart-define-from-file=env.json`. Nunca se hardcodean ni se usan ficheros
/// `.env` en la app (ver `specs/conventions.md`).
class Env {
  const Env._();

  /// URL del proyecto Supabase. Vacía si no se pasó `--dart-define-from-file`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Clave pública (anon) de Supabase. Segura en cliente porque el RLS protege
  /// los datos (ver `specs/architecture.md`).
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// `true` solo si ambas claves están presentes.
  static bool get isValid =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Mensaje legible que explica qué falta y cómo lanzar la app correctamente.
  static const String missingKeysMessage =
      'Faltan las claves de Supabase. Lanza la app con:\n\n'
      'flutter run --dart-define-from-file=env.json\n\n'
      'Comprueba que app/env.json define SUPABASE_URL y SUPABASE_ANON_KEY.';
}
