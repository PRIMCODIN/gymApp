import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/active_workout.dart';
import '../../domain/entities/previous_set_performance.dart';
import '../models/workout_model.dart';
import '../models/workout_set_model.dart';
import '../training_failure.dart';
import '../workout_previous_parser.dart';

/// Fuente de datos de la sesión de entreno: opera directo sobre Supabase con la
/// sesión del usuario (RLS). El entreno no pasa por n8n. Los errores se traducen
/// a [TrainingFailure] vía `mapTrainingError` (nada de fallos silenciosos).
class WorkoutSupabaseDataSource {
  const WorkoutSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Inserta la cabecera del workout (`finalizado=false`) y devuelve su `id`. Si
  /// la sesión arranca desde una rutina, se guarda su [routineId] para trazar el
  /// origen (la columna ya existe en `workouts`).
  Future<int> startWorkout(String nombre, {int? routineId}) async {
    final userId = _requireUserId();
    try {
      final row = await _client
          .from('workouts')
          .insert(
            WorkoutModel.toStartInsert(userId, nombre, routineId: routineId),
          )
          .select('id')
          .single();
      return (row['id'] as num).toInt();
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Lee el rendimiento anterior de [exerciseId]: sets de la última sesión
  /// finalizada del usuario con ese ejercicio, ordenados por `num_set`.
  ///
  /// El RLS limita los `workout_sets` a los del propio usuario (vía el workout
  /// padre); el `!inner` con `finalizado=true` descarta sesiones a medias. La
  /// elección de la sesión más reciente la hace [selectMostRecentWorkoutSets].
  Future<List<PreviousSetPerformance>> fetchPreviousPerformance(
    int exerciseId,
  ) async {
    try {
      final rows = await _client
          .from('workout_sets')
          .select('num_set, reps, peso, workout_id, workouts!inner(fecha)')
          .eq('exercise_id', exerciseId)
          .eq('workouts.finalizado', true);

      final candidates = rows.map((row) {
        final workout = row['workouts'] as Map<String, dynamic>;
        return PreviousSetCandidate(
          workoutId: (row['workout_id'] as num).toInt(),
          fecha: DateTime.parse(workout['fecha'] as String),
          performance: WorkoutSetModel.previousFromRow(row),
        );
      }).toList();

      return selectMostRecentWorkoutSets(candidates);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Cierra la sesión: primero inserta TODOS los sets y, solo si ese guardado va
  /// bien, marca el workout como finalizado. Este orden garantiza el caso pedido
  /// (si fallan los sets, el workout NO queda finalizado); sin RPC no hay
  /// transacción real, pero el esquema está cerrado.
  Future<void> finishWorkout(
    ActiveWorkout workout,
    int duracionSegundos,
  ) async {
    final userId = _requireUserId();
    try {
      final rows = <Map<String, dynamic>>[
        for (final exercise in workout.exercises)
          for (final set in exercise.sets)
            WorkoutSetModel.toInsert(workout.id, exercise, set),
      ];

      if (rows.isNotEmpty) {
        await _client.from('workout_sets').insert(rows);
      }

      await _client
          .from('workouts')
          .update(WorkoutModel.toFinishUpdate(duracionSegundos))
          .eq('id', workout.id)
          .eq('user_id', userId);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Borra la sesión iniciada (el cascade limpia sus sets si los hubiera).
  Future<void> cancelWorkout(int workoutId) async {
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
