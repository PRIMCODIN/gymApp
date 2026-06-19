import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Lee las comidas de HOY del usuario en sesión, más reciente primero.
  ///
  /// "Hoy" se filtra por `fecha` = fecha local actual (`YYYY-MM-DD`). El RLS
  /// limita la consulta a las filas del propio usuario; el `eq('user_id', ...)`
  /// es explícito por claridad.
  Future<List<FoodLogModel>> fetchToday() async {
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
          .eq('fecha', _today())
          .order('created_at', ascending: false);
      return rows.map(FoodLogModel.fromRow).toList();
    } catch (error) {
      throw mapNutritionError(error);
    }
  }

  /// Fecha local actual en formato `YYYY-MM-DD` para comparar con la columna
  /// `fecha` (tipo `date`) de `food_logs`.
  String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
