import 'package:app/features/nutrition/presentation/utils/day_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDayLabel', () {
    final today = DateTime(2026, 6, 19); // viernes

    test('el mismo día devuelve "Hoy"', () {
      expect(formatDayLabel(DateTime(2026, 6, 19), today), 'Hoy');
    });

    test('ignora la hora al comparar el día', () {
      expect(formatDayLabel(DateTime(2026, 6, 19, 23, 30), today), 'Hoy');
    });

    test('el día anterior devuelve "Ayer"', () {
      expect(formatDayLabel(DateTime(2026, 6, 18), today), 'Ayer');
    });

    test('otra fecha usa el formato corto en español', () {
      // 17 jun 2026 es miércoles.
      expect(formatDayLabel(DateTime(2026, 6, 17), today), 'mié 17 jun');
    });

    test('una fecha futura también usa el formato corto', () {
      // 21 jun 2026 es domingo.
      expect(formatDayLabel(DateTime(2026, 6, 21), today), 'dom 21 jun');
    });
  });
}
