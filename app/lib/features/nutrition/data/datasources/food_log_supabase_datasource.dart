import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_log_entry_model.dart';
import '../models/food_log_model.dart';
import '../nutrition_failure.dart';

/// Fuente de datos local-remota: inserta un registro de comida directo en
/// Supabase con la sesión del usuario. La escritura aquí es directa (no pasa por
/// n8n) porque guarda valores ya confirmados; el RLS garantiza que cada usuario
/// solo escribe sus propias filas.
class FoodLogSupabaseDataSource {
  const FoodLogSupabaseDataSource(this._client);

  final SupabaseClient _client;

  Future<void> insert(FoodLogModel model) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const NutritionFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    try {
      await _client.from('food_logs').insert(model.toInsert(userId));
    } catch (error) {
      throw mapNutritionError(error);
    }
  }

  /// Lee las comidas del día [date] del usuario en sesión, más reciente primero.
  ///
  /// Se filtra por `fecha` = fecha LOCAL de [date] (`YYYY-MM-DD`). El RLS limita
  /// la consulta a las filas del propio usuario; el `eq('user_id', ...)` es
  /// explícito por claridad.
  Future<List<FoodLogEntryModel>> fetchByDate(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const NutritionFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    try {
      final rows = await _client
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .eq('fecha', _formatDate(date))
          .order('created_at', ascending: false);
      return rows.map(FoodLogEntryModel.fromRow).toList();
    } catch (error) {
      throw mapNutritionError(error);
    }
  }

  /// Actualiza una comida existente por `id`. Solo toca las columnas editables
  /// (ver [FoodLogModel.toUpdate]). El `eq('user_id', ...)` es explícito; el RLS
  /// ya garantiza que solo afecta a filas propias.
  Future<void> update(int id, FoodLogModel model) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const NutritionFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    try {
      await _client
          .from('food_logs')
          .update(model.toUpdate())
          .eq('id', id)
          .eq('user_id', userId);
    } catch (error) {
      throw mapNutritionError(error);
    }
  }

  /// Borra una comida existente por `id`. El `eq('user_id', ...)` es explícito;
  /// el RLS ya garantiza que solo afecta a filas propias.
  Future<void> delete(int id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const NutritionFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    try {
      await _client
          .from('food_logs')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (error) {
      throw mapNutritionError(error);
    }
  }

  /// Fecha local en formato `YYYY-MM-DD` para comparar con la columna `fecha`
  /// (tipo `date`) de `food_logs`. Se usa la fecha local, no UTC.
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
