import '../entities/active_workout.dart';
import '../entities/previous_set_performance.dart';

/// Contrato de la sesión de entreno: persiste e interroga `workouts` /
/// `workout_sets` directo en Supabase con la sesión del usuario (respeta RLS).
///
/// El dominio no sabe nada de Supabase: solo pide iniciar, leer el rendimiento
/// anterior, finalizar o cancelar. El entreno NO usa IA ni n8n (lectura/escritura
/// directas, ver `specs/architecture.md`).
abstract class WorkoutRepository {
  /// Crea una sesión nueva (`finalizado=false`) y devuelve su `id`. Los sets se
  /// guardan luego, al finalizar. [routineId] traza el origen cuando la sesión
  /// arranca desde una rutina (null en el entreno libre).
  Future<int> startWorkout(String nombre, {int? routineId});

  /// Rendimiento de la ÚLTIMA sesión finalizada del usuario con [exerciseId],
  /// set a set y ordenado por `num_set`. Lista vacía si no hay histórico.
  Future<List<PreviousSetPerformance>> fetchPreviousPerformance(int exerciseId);

  /// Cierra la sesión: inserta todos los `workout_sets` (con snapshot de nombre y
  /// grupo muscular) y marca el `workout` como `finalizado=true` con su
  /// `duracion_s`. Los sets se guardan tal cual estén (reps/peso pueden ser null).
  Future<void> finishWorkout(ActiveWorkout workout, int duracionSegundos);

  /// Descarta una sesión iniciada: borra el `workout` (el cascade limpia sus sets
  /// si los hubiera).
  Future<void> cancelWorkout(int workoutId);
}
