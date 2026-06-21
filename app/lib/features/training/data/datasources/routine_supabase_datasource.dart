import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_exercise_item.dart';
import '../models/routine_exercise_model.dart';
import '../models/routine_model.dart';
import '../training_failure.dart';

/// Fuente de datos de las rutinas (plantillas): opera directo sobre Supabase con
/// la sesión del usuario (RLS). Las rutinas no pasan por n8n. Los errores se
/// traducen a [TrainingFailure] vía `mapTrainingError` (nada de fallos
/// silenciosos). Mismo patrón que `WorkoutSupabaseDataSource`.
class RoutineSupabaseDataSource {
  const RoutineSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Selección con join al catálogo para resolver el grupo muscular de cada item.
  static const String _routineSelect =
      'id, nombre, routine_exercises(id, exercise_id, nombre_ejercicio, orden, '
      'series_objetivo, dia_semana, exercises(grupo_muscular))';

  /// Cabeceras de las rutinas del usuario (con sus items para el resumen),
  /// ordenadas por fecha de creación descendente. El RLS limita a las propias.
  Future<List<Routine>> fetchRoutines() async {
    try {
      final rows = await _client
          .from('routines')
          .select(_routineSelect)
          .order('created_at', ascending: false);
      return rows.map(RoutineModel.fromRow).toList();
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Una rutina con sus items (ordenados por `orden` asc en el modelo).
  Future<Routine> fetchRoutineDetail(int routineId) async {
    try {
      final row = await _client
          .from('routines')
          .select(_routineSelect)
          .eq('id', routineId)
          .single();
      return RoutineModel.fromRow(row);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Inserta la cabecera, obtiene su `id` e inserta los items en bloque.
  Future<int> createRoutine(
    String nombre,
    List<RoutineExerciseItem> items,
  ) async {
    final userId = _requireUserId();
    try {
      final row = await _client
          .from('routines')
          .insert(RoutineModel.toInsert(userId, nombre))
          .select('id')
          .single();
      final routineId = (row['id'] as num).toInt();
      await _insertItems(routineId, items);
      return routineId;
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Actualiza la cabecera y REEMPLAZA los items (borra los viejos + inserta los
  /// nuevos): lo más fiable para soportar reordenado.
  Future<void> updateRoutine(
    int routineId,
    String nombre,
    List<RoutineExerciseItem> items,
  ) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('routines')
          .update({'nombre': nombre})
          .eq('id', routineId)
          .eq('user_id', userId);

      await _client
          .from('routine_exercises')
          .delete()
          .eq('routine_id', routineId);

      await _insertItems(routineId, items);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Borra la rutina (el cascade limpia sus `routine_exercises`).
  Future<void> deleteRoutine(int routineId) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('routines')
          .delete()
          .eq('id', routineId)
          .eq('user_id', userId);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Inserta los items de una rutina en bloque (no hace nada si la lista vacía).
  Future<void> _insertItems(
    int routineId,
    List<RoutineExerciseItem> items,
  ) async {
    if (items.isEmpty) return;
    final rows = [
      for (final item in items) RoutineExerciseModel.toInsert(routineId, item),
    ];
    await _client.from('routine_exercises').insert(rows);
  }

  /// Id del usuario en sesión o un [TrainingFailure] legible si expiró.
  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const TrainingFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }
    return userId;
  }
}
