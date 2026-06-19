import 'nutrition_estimate.dart';

/// Registro de comida que la app envía al guardar.
///
/// Contiene solo lo que el cliente aporta: la descripción y los valores
/// nutricionales confirmados por el usuario. El `id`, la `fecha` (default hoy) y
/// el `created_at` los rellena la base de datos, así que no viven aquí.
class FoodLog {
  const FoodLog({
    required this.descripcion,
    required this.nutrition,
  });

  final String descripcion;
  final NutritionEstimate nutrition;
}
