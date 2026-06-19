import 'package:supabase_flutter/supabase_flutter.dart';

import '../nutrition_failure.dart';

/// Fuente de datos que lee el objetivo de calorías del usuario directo de
/// Supabase (`profiles.objetivo_kcal_diario`) con su sesión. Lectura directa, el
/// RLS limita la fila a la del propio usuario (ver `specs/architecture.md`).
class CalorieGoalSupabaseDataSource {
  const CalorieGoalSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Default cuando el perfil aún no tiene objetivo (coincide con el de la BD).
  static const int _defaultGoal = 2000;

  Future<int> fetchDailyGoal() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const NutritionFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    try {
      final row = await _client
          .from('profiles')
          .select('objetivo_kcal_diario')
          .eq('id', userId)
          .maybeSingle();

      final value = row?['objetivo_kcal_diario'];
      if (value is int) return value;
      if (value is num) return value.round();
      return _defaultGoal;
    } catch (error) {
      throw mapNutritionError(error);
    }
  }
}
