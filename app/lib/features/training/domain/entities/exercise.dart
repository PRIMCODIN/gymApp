/// Ejercicio del catálogo de Entreno.
///
/// Dos tipos conviven en la misma entidad (ver `exercises` en
/// `db/schema_entreno.sql`):
///   · Predefinido global ([userId] == null): sembrado por nosotros, visible para
///     todos. El usuario no puede editarlo ni borrarlo.
///   · Personalizado ([userId] != null): lo crea el usuario cuando su ejercicio no
///     está en la lista. Solo lo ve su dueño.
/// El grupo muscular vive en el ejercicio (no en cada set): un ejercicio "sabe" su
/// músculo. Entidad pura de dominio: sin Flutter ni Supabase.
class Exercise {
  const Exercise({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.grupoMuscular,
  });

  final int id;

  /// Dueño del ejercicio. `null` = predefinido global; no-null = personalizado.
  final String? userId;

  final String nombre;

  /// Grupo muscular granular (p. ej. `pecho`, `cuadriceps`, `hombro_anterior`).
  final String grupoMuscular;

  /// `true` si es un ejercicio personalizado del usuario (tiene dueño).
  bool get isCustom => userId != null;

  /// `true` si es un ejercicio predefinido global (sin dueño).
  bool get isPredefined => userId == null;
}
