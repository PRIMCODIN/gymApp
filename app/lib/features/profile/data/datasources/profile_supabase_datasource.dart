import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/personal_data.dart';
import '../models/profile_model.dart';
import '../profile_failure.dart';

/// Fuente de datos que lee y escribe el perfil del usuario directo en Supabase
/// (`profiles`) con su sesión. Lectura y escritura directas (no pasan por n8n):
/// es un guardado simple sin IA. El RLS limita la fila a la del propio usuario
/// (`auth.uid() = id`); el `eq('id', userId)` explícito es por claridad.
class ProfileSupabaseDataSource {
  const ProfileSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Columnas relevantes del perfil (las de `specs/perfil.md`). `plan` se lee
  /// para mostrar el badge, nunca se escribe.
  static const String _columns =
      'nombre, objetivo_kcal_diario, plan, sexo, fecha_nacimiento, '
      'altura_cm, peso_kg, nivel_actividad, objetivo';

  Future<ProfileModel> fetchProfile() async {
    final userId = _requireUserId();
    try {
      final row = await _client
          .from('profiles')
          .select(_columns)
          .eq('id', userId)
          .maybeSingle();

      if (row == null) {
        // El trigger crea la fila al registrarse; si no existe, algo va mal.
        throw const ProfileFailure(
          'No se encontró tu perfil. Vuelve a iniciar sesión.',
        );
      }
      return ProfileModel.fromRow(row);
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Actualiza solo `objetivo_kcal_diario`.
  Future<void> updateCalorieGoal(int goal) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('profiles')
          .update(ProfileModel.calorieGoalUpdate(goal))
          .eq('id', userId);
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Actualiza los seis datos antropométricos (un `null` limpia la columna).
  /// Nunca envía `plan`.
  Future<void> updatePersonalData(PersonalData data) async {
    final userId = _requireUserId();
    try {
      await _client
          .from('profiles')
          .update(ProfileModel.personalDataUpdate(data))
          .eq('id', userId);
    } catch (error) {
      throw mapProfileError(error);
    }
  }

  /// Id del usuario en sesión, o lanza un [ProfileFailure] legible si expiró.
  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ProfileFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }
    return userId;
  }
}
