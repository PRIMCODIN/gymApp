import '../entities/food_log.dart';

/// Contrato para persistir y leer registros de comida.
///
/// La implementación vive en data y opera directo sobre Supabase con la sesión
/// del usuario (respeta RLS). El dominio no sabe nada de Supabase: solo pide
/// guardar o leer. Tanto la escritura como la lectura son directas (no pasan por
/// n8n): se guardan valores ya confirmados y se leen datos propios bajo RLS.
abstract class FoodLogRepository {
  /// Guarda un registro de comida del usuario en sesión.
  Future<void> save(FoodLog log);

  /// Comidas registradas HOY por el usuario en sesión, más reciente primero.
  Future<List<FoodLog>> fetchToday();
}
