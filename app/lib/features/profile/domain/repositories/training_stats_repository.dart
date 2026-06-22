/// Contrato de stats de entreno mostradas en el Perfil. Solo lectura: cuentas
/// agregadas de `workouts` finalizados del usuario en sesión (el RLS las limita
/// a los propios). Implementado en data con count directo a Supabase.
abstract class TrainingStatsRepository {
  /// Nº total de workouts del usuario con `finalizado = true`.
  Future<int> countFinishedWorkouts();

  /// Nº de workouts finalizados con `fecha` dentro del mes natural actual.
  Future<int> countFinishedWorkoutsThisMonth();

  /// Fechas de todos los workouts finalizados del usuario (una por sesión).
  /// Alimentan el cálculo de la racha semanal en dominio.
  Future<List<DateTime>> fetchFinishedWorkoutDates();
}
