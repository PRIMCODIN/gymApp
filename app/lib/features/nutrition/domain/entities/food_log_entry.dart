import 'nutrition_estimate.dart';

/// Registro de comida tal y como se LEE de la base de datos.
///
/// A diferencia de [FoodLog] (lo que la app envía al guardar), aquí el `id` y la
/// `fecha` vienen siempre rellenos por la BD, por eso son NO nullables. Se usa
/// para listar las comidas de un día, editarlas o borrarlas (necesita el `id`).
/// Reutiliza [NutritionEstimate] como value object de macros.
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.fecha,
    required this.descripcion,
    required this.nutrition,
  });

  final int id;
  final DateTime fecha;
  final String descripcion;
  final NutritionEstimate nutrition;
}
