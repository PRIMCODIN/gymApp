import '../entities/routine.dart';
import '../entities/routine_exercise_item.dart';

/// Contrato de las rutinas (plantillas): lee y escribe `routines` /
/// `routine_exercises` directo en Supabase con la sesión del usuario (respeta
/// RLS: rutina propia / ejercicios validados vía padre).
///
/// El dominio no sabe nada de Supabase. Las rutinas NO usan IA ni n8n
/// (lectura/escritura directas, ver `specs/architecture.md`).
abstract class RoutineRepository {
  /// Cabeceras de las rutinas del usuario, ordenadas (incluye sus items para
  /// poder mostrar un resumen en el listado).
  Future<List<Routine>> fetchRoutines();

  /// Una rutina con sus items completos, ordenados por `orden` asc.
  Future<Routine> fetchRoutineDetail(int routineId);

  /// Crea la rutina (cabecera + sus `routine_exercises`) y devuelve su `id`.
  Future<int> createRoutine(String nombre, List<RoutineExerciseItem> items);

  /// Actualiza la cabecera y REEMPLAZA sus items (borra los viejos e inserta los
  /// nuevos): lo más simple y fiable para soportar reordenado.
  Future<void> updateRoutine(
    int routineId,
    String nombre,
    List<RoutineExerciseItem> items,
  );

  /// Borra la rutina (el cascade limpia sus `routine_exercises`).
  Future<void> deleteRoutine(int routineId);
}
