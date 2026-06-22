import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile_failure.dart';

/// Fuente de datos de las stats de entreno del Perfil. Lee directo de Supabase
/// con la sesión del usuario (RLS), sin pasar por n8n (es solo lectura). Usa el
/// `count` de PostgREST (head-only): NO trae filas, solo el número. Los errores
/// se traducen a [ProfileFailure] vía `mapProfileError` (nada de fallos
/// silenciosos). El RLS de `workouts` ya limita a los propios.
class TrainingStatsSupabaseDataSource {
  const TrainingStatsSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Nº total de workouts del usuario con `finalizado = true`.
  Future<int> countFinishedWorkouts() async {
    _requireUserId();
    try {
      return await _client
          .from('workouts')
          .count(CountOption.exact)
          .eq('finalizado', true);
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Nº de workouts finalizados con `fecha` dentro del mes natural actual.
  Future<int> countFinishedWorkoutsThisMonth() async {
    _requireUserId();
    try {
      final now = DateTime.now();
      final first = DateTime(now.year, now.month, 1);
      final last = DateTime(now.year, now.month + 1, 0);
      return await _client
          .from('workouts')
          .count(CountOption.exact)
          .eq('finalizado', true)
          .gte('fecha', _formatDate(first))
          .lte('fecha', _formatDate(last));
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Fechas de todos los workouts del usuario con `finalizado = true`. Solo trae
  /// la columna `fecha` (una fila por workout finalizado), que alimenta el
  /// cálculo de la racha semanal en dominio. El RLS de `workouts` ya limita a los
  /// propios; los errores se traducen a [ProfileFailure].
  Future<List<DateTime>> fetchFinishedWorkoutDates() async {
    _requireUserId();
    try {
      final rows = await _client
          .from('workouts')
          .select('fecha')
          .eq('finalizado', true);
      return rows
          .map((row) => DateTime.parse(row['fecha'] as String))
          .toList();
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Fecha local en formato `YYYY-MM-DD` para comparar con la columna `fecha`
  /// (tipo `date`). Se usa la fecha local, no UTC (mismo criterio que el resto
  /// de la app).
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Verifica que hay sesión; si no, lanza un [ProfileFailure] legible en vez de
  /// dejar que el count devuelva 0 en silencio.
  void _requireUserId() {
    if (_client.auth.currentUser?.id == null) {
      throw const ProfileFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }
  }
}
