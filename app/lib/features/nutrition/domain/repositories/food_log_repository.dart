import '../entities/food_log.dart';
import '../entities/food_log_entry.dart';

/// Contrato para persistir y leer registros de comida.
///
/// La implementación vive en data y opera directo sobre Supabase con la sesión
/// del usuario (respeta RLS). El dominio no sabe nada de Supabase: solo pide
/// guardar, leer, editar o borrar. La escritura simple y la lectura son directas
/// (no pasan por n8n): se guardan valores ya confirmados y se leen datos propios
/// bajo RLS.
abstract class FoodLogRepository {
  /// Guarda un registro de comida del usuario en sesión.
  Future<void> save(FoodLog log);

  /// Comidas registradas el día [date] por el usuario en sesión, más reciente
  /// primero.
  Future<List<FoodLogEntry>> fetchByDate(DateTime date);

  /// Actualiza los campos editables (descripción + macros) de la comida [id].
  Future<void> update(int id, FoodLog log);

  /// Borra la comida [id].
  Future<void> delete(int id);
}
