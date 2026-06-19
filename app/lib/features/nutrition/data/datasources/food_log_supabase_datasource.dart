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
}
