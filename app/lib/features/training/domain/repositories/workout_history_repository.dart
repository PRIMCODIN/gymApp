import '../entities/workout_detail.dart';
import '../entities/workout_summary.dart';

/// Contrato de lectura del historial de entrenos finalizados (y borrado de un
/// workout). Lectura directa a Supabase con la sesión del usuario (RLS); el
/// borrado sigue el precedente del Entreno (directo, sin n8n). Devuelve
/// `Future<T>` directo (sin Either), como el resto de repositorios.
abstract class WorkoutHistoryRepository {
  /// Días con al menos un workout finalizado en el mes [month] (1-12) de [year],
  /// para pintar los marcadores del calendario.
  Future<Set<DateTime>> fetchWorkoutDatesForMonth(int year, int month);

  /// Workouts finalizados de un [day] concreto (con su resumen ya calculado).
  Future<List<WorkoutSummary>> fetchWorkoutsForDay(DateTime day);

  /// Detalle completo de un workout (ejercicios -> sets ordenados).
  Future<WorkoutDetail> fetchWorkoutDetail(int workoutId);

  /// Borra el workout entero (el cascade limpia sus `workout_sets`).
  Future<void> deleteWorkout(int workoutId);
}
