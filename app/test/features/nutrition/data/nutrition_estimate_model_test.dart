import 'package:app/features/nutrition/data/models/nutrition_estimate_model.dart';
import 'package:app/features/nutrition/data/nutrition_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionEstimateModel.fromJson', () {
    test('parsea la respuesta de n8n con claves en español', () {
      final model = NutritionEstimateModel.fromJson({
        'kcal': 520,
        'proteina': 35.5,
        'carbos': 60,
        'grasa': 12.2,
      });

      expect(model.kcal, 520.0);
      expect(model.proteina, 35.5);
      expect(model.carbos, 60.0);
      expect(model.grasa, 12.2);
    });

    test('tolera valores numéricos enviados como texto (incl. coma decimal)', () {
      final model = NutritionEstimateModel.fromJson({
        'kcal': '520',
        'proteina': '35,5',
        'carbos': '60',
        'grasa': '12.2',
      });

      expect(model.kcal, 520.0);
      expect(model.proteina, 35.5);
      expect(model.carbos, 60.0);
      expect(model.grasa, 12.2);
    });

    test('lanza NutritionFailure si falta un campo', () {
      expect(
        () => NutritionEstimateModel.fromJson({
          'kcal': 520,
          'proteina': 35.5,
          'carbos': 60,
          // falta "grasa"
        }),
        throwsA(isA<NutritionFailure>()),
      );
    });

    test('lanza NutritionFailure si un campo no es numérico', () {
      expect(
        () => NutritionEstimateModel.fromJson({
          'kcal': 520,
          'proteina': 'mucha',
          'carbos': 60,
          'grasa': 12.2,
        }),
        throwsA(isA<NutritionFailure>()),
      );
    });

    test('lanza NutritionFailure si un campo es null', () {
      expect(
        () => NutritionEstimateModel.fromJson({
          'kcal': null,
          'proteina': 35.5,
          'carbos': 60,
          'grasa': 12.2,
        }),
        throwsA(isA<NutritionFailure>()),
      );
    });
  });
}
