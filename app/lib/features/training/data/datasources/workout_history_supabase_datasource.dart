import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/workout_detail.dart';
import '../../domain/entities/workout_summary.dart';
import '../models/workout_detail_model.dart';
import '../models/workout_summary_model.dart';
import '../training_failure.dart';

/// Fuente de datos del historial de entrenos: lee directo de Supabase con la
/// sesión del usuario (RLS), sin pasar por n8n (igual que el resto del Entreno).
/// Los errores se traducen a [TrainingFailure] vía `mapTrainingError` (nada de
/// fallos silenciosos). Solo trabaja con workouts finalizados.
class WorkoutHistorySupabaseDataSource {
  const WorkoutHistorySupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Fechas (locales, normalizadas a medianoche) con al menos un workout
  /// finalizado en el mes [month] (1-12) de [year]. El RLS limita a los propios.
  Future<Set<DateTime>> fetchWorkoutDatesForMonth(int year, int month) async {
    try {
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);
      final rows = await _client
          .from('workouts')
          .select('fecha')
          .eq('finalizado', true)
          .gte('fecha', _formatDate(first))
          .lte('fecha', _formatDate(last));

      return {for (final row in rows) parseLocalDate(row['fecha'])};
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Workouts finalizados de un [day], con su resumen (nº ejercicios/sets y
  /// volumen) calculado a partir de sus `workout_sets`.
  Future<List<WorkoutSummary>> fetchWorkoutsForDay(DateTime day) async {
    try {
      final workoutRows = await _client
          .from('workouts')
          .select('id, nombre, fecha, duracion_s')
          .eq('finalizado', true)
          .eq('fecha', _formatDate(day))
          .order('created_at', ascending: false);

      if (workoutRows.isEmpty) return [];

      final ids = [for (final row in workoutRows) (row['id'] as num).toInt()];
      final setRows = await _client
          .from('workout_sets')
          .select(
            'workout_id, orden_ejercicio, nombre_ejercicio, grupo_muscular, '
            'num_set, reps, peso, completado',
          )
          .inFilter('workout_id', ids);

      // Agrupa los sets por workout para construir cada resumen.
      final setsByWorkout = <int, List<Map<String, dynamic>>>{};
      for (final row in setRows) {
        final workoutId = (row['workout_id'] as num).toInt();
        setsByWorkout.putIfAbsent(workoutId, () => []).add(row);
      }

      return [
        for (final workoutRow in workoutRows)
          WorkoutSummaryModel.fromWorkoutAndSets(
            workoutRow,
            setsByWorkout[(workoutRow['id'] as num).toInt()] ?? const [],
          ),
      ];
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Detalle de un workout: cabecera + sus `workout_sets` ordenados por
  /// `orden_ejercicio` y `num_set`, agrupados en ejercicios -> sets.
  Future<WorkoutDetail> fetchWorkoutDetail(int workoutId) async {
    try {
      final workoutRow = await _client
          .from('workouts')
          .select('id, nombre, fecha, duracion_s')
          .eq('id', workoutId)
          .single();

      final setRows = await _client
          .from('workout_sets')
          .select(
            'exercise_id, orden_ejercicio, nombre_ejercicio, grupo_muscular, '
            'num_set, reps, peso, completado, rpe',
          )
          .eq('workout_id', workoutId)
          .order('orden_ejercicio')
          .order('num_set');

      return WorkoutDetailModel.fromRows(workoutRow, setRows);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Guarda la edición de un workout pasado: actualiza la cabecera (`nombre`,
  /// `fecha`) y REEMPLAZA sus `workout_sets` por el estado editado. Sigue la misma
  /// estrategia delete-then-insert que `updateRoutine`: UPDATE cabecera -> DELETE
  /// de los sets viejos -> INSERT de los editados. No se puede insertar antes de
  /// borrar (FK al mismo `workout_id`); si algo falla, el detalle se recarga desde
  /// BD al invalidar su provider. El RLS limita a los workouts propios.
  Future<void> updateWorkout(
    int workoutId,
    String nombre,
    DateTime fecha,
    List<WorkoutDetailExercise> exercises,
  ) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('workouts')
          .update({'nombre': nombre, 'fecha': _formatDate(fecha)})
          .eq('id', workoutId)
          .eq('user_id', userId);

      await _client.from('workout_sets').delete().eq('workout_id', workoutId);

      final rows = WorkoutDetailModel.toInsertRows(workoutId, exercises);
      if (rows.isNotEmpty) {
        await _client.from('workout_sets').insert(rows);
      }
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Borra el workout (el cascade limpia sus `workout_sets`).
  Future<void> deleteWorkout(int workoutId) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('workouts')
          .delete()
          .eq('id', workoutId)
          .eq('user_id', userId);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Fecha local en formato `YYYY-MM-DD` para comparar con la columna `fecha`
  /// (tipo `date`). Se usa la fecha local, no UTC (mismo criterio que el resto de
  /// la app).
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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
