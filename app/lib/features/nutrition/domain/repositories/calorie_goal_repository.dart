/// Contrato para leer el objetivo de calorías diario del usuario.
///
/// La implementación vive en data y lee directo de Supabase
/// (`profiles.objetivo_kcal_diario`) con la sesión del usuario (respeta RLS).
/// Lectura directa, no pasa por n8n (ver `specs/architecture.md`).
abstract class CalorieGoalRepository {
  /// Objetivo de kcal diario del usuario en sesión (default 2000 si no hay dato).
  Future<int> fetchDailyGoal();
}
