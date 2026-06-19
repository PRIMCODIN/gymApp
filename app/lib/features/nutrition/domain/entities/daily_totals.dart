import 'food_log.dart';

/// Totales nutricionales del día: suma de kcal y macros de una lista de comidas.
///
/// Value object de dominio (Dart puro). El cálculo vive aquí, fuera de los
/// widgets, para que sea reutilizable y testeable. La barra de calorías y el
/// desglose de macros de la pantalla del día se construyen a partir de esto.
class DailyTotals {
  const DailyTotals({
    required this.kcal,
    required this.proteina,
    required this.carbos,
    required this.grasa,
  });

  /// Totales a cero (día sin comidas registradas).
  static const DailyTotals zero =
      DailyTotals(kcal: 0, proteina: 0, carbos: 0, grasa: 0);

  /// Suma los valores nutricionales de todas las comidas de [logs].
  factory DailyTotals.fromLogs(List<FoodLog> logs) {
    var kcal = 0.0;
    var proteina = 0.0;
    var carbos = 0.0;
    var grasa = 0.0;
    for (final log in logs) {
      kcal += log.nutrition.kcal;
      proteina += log.nutrition.proteina;
      carbos += log.nutrition.carbos;
      grasa += log.nutrition.grasa;
    }
    return DailyTotals(
      kcal: kcal,
      proteina: proteina,
      carbos: carbos,
      grasa: grasa,
    );
  }

  final double kcal;
  final double proteina;
  final double carbos;
  final double grasa;
}
