import 'package:app/features/nutrition/domain/entities/daily_totals.dart';
import 'package:app/features/nutrition/domain/entities/food_log_entry.dart';
import 'package:app/features/nutrition/domain/entities/nutrition_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

FoodLogEntry _log({
  required double kcal,
  required double proteina,
  required double carbos,
  required double grasa,
}) {
  return FoodLogEntry(
    id: 1,
    fecha: DateTime(2026, 6, 19),
    descripcion: 'comida',
    nutrition: NutritionEstimate(
      kcal: kcal,
      proteina: proteina,
      carbos: carbos,
      grasa: grasa,
    ),
  );
}

void main() {
  group('DailyTotals.fromLogs', () {
    test('devuelve cero con una lista vacía', () {
      final totals = DailyTotals.fromLogs(const []);

      expect(totals.kcal, 0);
      expect(totals.proteina, 0);
      expect(totals.carbos, 0);
      expect(totals.grasa, 0);
    });

    test('refleja los valores de una única comida', () {
      final totals = DailyTotals.fromLogs([
        _log(kcal: 520, proteina: 35.5, carbos: 60, grasa: 12.2),
      ]);

      expect(totals.kcal, 520);
      expect(totals.proteina, 35.5);
      expect(totals.carbos, 60);
      expect(totals.grasa, 12.2);
    });

    test('suma kcal y macros de varias comidas', () {
      final totals = DailyTotals.fromLogs([
        _log(kcal: 500, proteina: 30, carbos: 50, grasa: 10),
        _log(kcal: 250.5, proteina: 20.5, carbos: 15, grasa: 5.5),
        _log(kcal: 100, proteina: 0, carbos: 25, grasa: 0),
      ]);

      expect(totals.kcal, 850.5);
      expect(totals.proteina, 50.5);
      expect(totals.carbos, 90);
      expect(totals.grasa, 15.5);
    });
  });
}
