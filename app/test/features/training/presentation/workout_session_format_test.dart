import 'package:app/features/training/domain/entities/previous_set_performance.dart';
import 'package:app/features/training/presentation/utils/workout_session_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('workoutDurationSeconds', () {
    test('cuenta los segundos entre inicio y fin', () {
      final start = DateTime(2026, 6, 21, 10, 0, 0);
      final end = DateTime(2026, 6, 21, 10, 45, 30);
      expect(workoutDurationSeconds(start, end), 45 * 60 + 30);
    });

    test('mismo instante → 0', () {
      final t = DateTime(2026, 6, 21, 10);
      expect(workoutDurationSeconds(t, t), 0);
    });

    test('fin antes que inicio → 0 (nunca negativo)', () {
      final start = DateTime(2026, 6, 21, 10, 0, 10);
      final end = DateTime(2026, 6, 21, 10, 0, 0);
      expect(workoutDurationSeconds(start, end), 0);
    });
  });

  group('formatStopwatch', () {
    test('por debajo de una hora usa mm:ss', () {
      expect(formatStopwatch(const Duration(seconds: 5)), '00:05');
      expect(
        formatStopwatch(const Duration(minutes: 7, seconds: 9)),
        '07:09',
      );
      expect(
        formatStopwatch(const Duration(minutes: 59, seconds: 59)),
        '59:59',
      );
    });

    test('a partir de una hora usa h:mm:ss', () {
      expect(
        formatStopwatch(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('duración negativa → 00:00', () {
      expect(formatStopwatch(const Duration(seconds: -10)), '00:00');
    });
  });

  group('previousForSet', () {
    final previous = [
      const PreviousSetPerformance(numSet: 1, reps: 8, peso: 60),
      const PreviousSetPerformance(numSet: 2, reps: 6, peso: 65),
    ];

    test('devuelve el rendimiento del set con ese num_set', () {
      final match = previousForSet(previous, 2);
      expect(match, isNotNull);
      expect(match!.reps, 6);
      expect(match.peso, 65);
    });

    test('sin coincidencia → null', () {
      expect(previousForSet(previous, 3), isNull);
    });

    test('lista vacía → null', () {
      expect(previousForSet(const [], 1), isNull);
    });
  });
}
