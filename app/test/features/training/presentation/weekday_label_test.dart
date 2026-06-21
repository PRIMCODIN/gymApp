import 'package:app/features/training/presentation/utils/weekday_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weekdayLabel', () {
    test('1 → Lunes, 7 → Domingo', () {
      expect(weekdayLabel(1), 'Lunes');
      expect(weekdayLabel(7), 'Domingo');
    });

    test('días intermedios', () {
      expect(weekdayLabel(3), 'Miércoles');
      expect(weekdayLabel(6), 'Sábado');
    });

    test('null → Sin día', () {
      expect(weekdayLabel(null), 'Sin día');
    });

    test('fuera de rango → Sin día (nunca rompe la UI)', () {
      expect(weekdayLabel(0), 'Sin día');
      expect(weekdayLabel(8), 'Sin día');
      expect(weekdayLabel(-1), 'Sin día');
    });

    test('kWeekdays cubre lunes..domingo en orden', () {
      expect(kWeekdays, [1, 2, 3, 4, 5, 6, 7]);
    });
  });
}
