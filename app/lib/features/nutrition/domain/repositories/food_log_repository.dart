import '../entities/food_log.dart';

/// Contrato para persistir un registro de comida.
///
/// La implementación vive en data y guarda directo en Supabase con la sesión del
/// usuario (respeta RLS). El dominio no sabe nada de Supabase: solo pide guardar.
abstract class FoodLogRepository {
  Future<void> save(FoodLog log);
}
