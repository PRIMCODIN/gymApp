/// Estimación nutricional de una comida: kcal y macros.
///
/// Entidad de dominio (Dart puro, sin Flutter ni Supabase). La devuelve la IA
/// (vía n8n) y también representa los valores ya editados por el usuario antes
/// de guardar. Los macros se modelan como `double` para alinear con el tipo
/// `numeric` de la BD; `kcal` se castea a entero al persistir.
class NutritionEstimate {
  const NutritionEstimate({
    required this.kcal,
    required this.proteina,
    required this.carbos,
    required this.grasa,
  });

  final double kcal;
  final double proteina;
  final double carbos;
  final double grasa;
}
