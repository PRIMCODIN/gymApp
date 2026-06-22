/// Perfil del usuario, modelo de negocio puro.
///
/// Capa domain: Dart puro, sin dependencias de Flutter ni Supabase
/// (ver `specs/languageArchitecture.md`). Espejo en BD de la tabla `profiles`
/// (columnas en español); aquí los campos van en inglés según la convención del
/// proyecto. Los valores de los enums de texto ([sex], [activityLevel], [goal])
/// se conservan en español tal cual están en BD, porque son lo que validan los
/// CHECK; la UI los traduce a etiquetas legibles.
class Profile {
  const Profile({
    required this.name,
    required this.kcalGoal,
    required this.plan,
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
  });

  /// Nombre mostrado (`profiles.nombre`). Nullable; solo lectura en esta pantalla.
  final String? name;

  /// Objetivo de kcal diario (`objetivo_kcal_diario`). Editable. `null` si el
  /// usuario aún no lo ha fijado (no se inventa un default).
  final int? kcalGoal;

  /// Plan del usuario (`plan`): `'free'` | `'pro'`. Read-only (lo protege el
  /// trigger `lock_plan`); nunca se escribe desde el cliente.
  final String plan;

  /// Sexo (`sexo`): `'hombre'` | `'mujer'`. Nullable.
  final String? sex;

  /// Fecha de nacimiento (`fecha_nacimiento`). Se guarda la fecha, no la edad.
  final DateTime? birthDate;

  /// Altura en cm (`altura_cm`): 80–260. Nullable.
  final int? heightCm;

  /// Peso en kg (`peso_kg`): 25–400. Nullable.
  final double? weightKg;

  /// Nivel de actividad (`nivel_actividad`):
  /// `sedentario`|`ligero`|`moderado`|`activo`|`muy_activo`. Nullable.
  final String? activityLevel;

  /// Objetivo (`objetivo`): `perder`|`mantener`|`ganar`. Nullable.
  final String? goal;
}
