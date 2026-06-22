import 'package:app/features/home/presentation/utils/relative_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('relativeDayLabel', () {
    test('mismo día (distinta hora) -> "hoy"', () {
      final label = relativeDayLabel(
        DateTime(2026, 6, 22, 18),
        now: DateTime(2026, 6, 22, 9),
      );

      expect(label, 'hoy');
    });

    test('día anterior -> "ayer"', () {
      final label = relativeDayLabel(
        DateTime(2026, 6, 21),
        now: DateTime(2026, 6, 22),
      );

      expect(label, 'ayer');
    });

    test('hace 3 días -> "hace 3 días"', () {
      final label = relativeDayLabel(
        DateTime(2026, 6, 19),
        now: DateTime(2026, 6, 22),
      );

      expect(label, 'hace 3 días');
    });

    test('borde 1->2 días -> "hace 2 días"', () {
      final label = relativeDayLabel(
        DateTime(2026, 6, 20),
        now: DateTime(2026, 6, 22),
      );

      expect(label, 'hace 2 días');
    });

    test('corte por día, no por horas: ayer 23h vs hoy 1h -> "ayer"', () {
      final label = relativeDayLabel(
        DateTime(2026, 6, 21, 23),
        now: DateTime(2026, 6, 22, 1),
      );

      expect(label, 'ayer');
    });
  });
}
