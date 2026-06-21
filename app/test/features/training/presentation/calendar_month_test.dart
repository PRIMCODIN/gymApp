import 'package:app/features/training/presentation/utils/calendar_month.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('daysInMonth', () {
    test('meses de 31, 30 y 28 días', () {
      expect(daysInMonth(2026, 1), 31); // enero
      expect(daysInMonth(2026, 4), 30); // abril
      expect(daysInMonth(2026, 2), 28); // febrero no bisiesto
    });

    test('febrero bisiesto', () {
      expect(daysInMonth(2024, 2), 29);
      expect(daysInMonth(2000, 2), 29); // múltiplo de 400
      expect(daysInMonth(1900, 2), 28); // múltiplo de 100 no de 400
    });
  });

  group('firstWeekdayOfMonth', () {
    test('ISO: 1 = lunes ... 7 = domingo', () {
      // 1 de junio de 2026 es lunes.
      expect(firstWeekdayOfMonth(2026, 6), 1);
      // 1 de febrero de 2026 es domingo.
      expect(firstWeekdayOfMonth(2026, 2), 7);
    });
  });

  group('monthRange', () {
    test('primer y último día del mes', () {
      final range = monthRange(2026, 2);
      expect(range.first, DateTime(2026, 2, 1));
      expect(range.last, DateTime(2026, 2, 28));

      final leap = monthRange(2024, 2);
      expect(leap.last, DateTime(2024, 2, 29));
    });
  });

  group('isSameDay', () {
    test('ignora la hora', () {
      expect(
        isSameDay(DateTime(2026, 6, 21, 9), DateTime(2026, 6, 21, 23, 59)),
        isTrue,
      );
      expect(isSameDay(DateTime(2026, 6, 21), DateTime(2026, 6, 22)), isFalse);
    });
  });

  group('monthYearLabel', () {
    test('mes en español + año', () {
      expect(monthYearLabel(2026, 6), 'junio 2026');
      expect(monthYearLabel(2026, 1), 'enero 2026');
    });
  });
}
