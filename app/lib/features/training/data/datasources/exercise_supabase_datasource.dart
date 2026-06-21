import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exercise_model.dart';
import '../training_failure.dart';

/// Fuente de datos del catálogo de ejercicios: lee y escribe directo en Supabase
/// con la sesión del usuario. El RLS garantiza que cada usuario solo ve los
/// globales + los suyos, y solo escribe los suyos.
class ExerciseSupabaseDataSource {
  const ExerciseSupabaseDataSource(this._client);

  final SupabaseClient _client;

  /// Lee el catálogo visible (globales + propios), ordenado por nombre. No hace
  /// falta filtrar por `user_id`: la policy de SELECT ya devuelve `user_id is
  /// null or auth.uid() = user_id`.
  Future<List<ExerciseModel>> fetchCatalog() async {
    try {
      final rows = await _client
          .from('exercises')
          .select()
          .order('nombre', ascending: true);
      return rows.map(ExerciseModel.fromRow).toList();
    } catch (error) {
      throw mapTrainingError(error);
    }
  }

  /// Inserta un ejercicio personalizado del usuario en sesión y devuelve la fila
  /// creada (con su `id`). El `user_id` del payload debe coincidir con
  /// `auth.uid()` o el RLS rechaza el insert.
  Future<ExerciseModel> insertCustom(String nombre, String grupoMuscular) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const TrainingFailure(
        'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }

    final model = ExerciseModel(
      id: 0,
      userId: userId,
      nombre: nombre,
      grupoMuscular: grupoMuscular,
    );

    try {
      final row = await _client
          .from('exercises')
          .insert(model.toInsert(userId))
          .select()
          .single();
      return ExerciseModel.fromRow(row);
    } catch (error) {
      throw mapTrainingError(error);
    }
  }
}
