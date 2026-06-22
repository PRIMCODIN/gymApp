import '../entities/personal_data.dart';
import '../entities/profile.dart';

/// Contrato para leer y actualizar el perfil del usuario en sesión.
///
/// La implementación vive en data y lee/escribe directo de Supabase sobre la
/// tabla `profiles` con la sesión del usuario (respeta RLS). Lectura y escritura
/// directas, no pasan por n8n: es un guardado simple sin IA (ver
/// `specs/architecture.md`). `plan` nunca se escribe desde el cliente.
abstract class ProfileRepository {
  /// Perfil del usuario en sesión (kcalGoal cae a 2000 si no hay dato).
  Future<Profile> fetchProfile();

  /// Actualiza solo `objetivo_kcal_diario`.
  Future<void> updateCalorieGoal(int goal);

  /// Actualiza los seis datos antropométricos. Un campo `null` limpia su columna.
  Future<void> updatePersonalData(PersonalData data);
}
