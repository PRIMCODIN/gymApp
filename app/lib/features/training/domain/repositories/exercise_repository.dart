import '../entities/exercise.dart';

/// Contrato para leer y crear ejercicios del catálogo de Entreno.
///
/// La implementación vive en data y opera directo sobre Supabase con la sesión
/// del usuario (respeta RLS). El dominio no sabe nada de Supabase: solo pide leer
/// el catálogo o crear un ejercicio personalizado. La lectura y la escritura son
/// directas (no pasan por n8n): el entreno se registra a mano, sin IA.
abstract class ExerciseRepository {
  /// Ejercicios visibles para el usuario en sesión (globales + propios),
  /// ordenados por nombre. El RLS ya limita la consulta a lo que puede ver.
  Future<List<Exercise>> fetchCatalog();

  /// Crea un ejercicio personalizado del usuario en sesión y devuelve el
  /// ejercicio creado (con su `id` ya asignado por la BD).
  Future<Exercise> createCustom(String nombre, String grupoMuscular);
}
