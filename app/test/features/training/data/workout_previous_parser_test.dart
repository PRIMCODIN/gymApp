import 'package:app/features/training/data/workout_previous_parser.dart';
import 'package:app/features/training/domain/entities/previous_set_performance.dart';
import 'package:flutter_test/flutter_test.dart';

PreviousSetCandidate _candidate(
  int workoutId,
  DateTime fecha,
  int numSet, {
  int? reps,
  double? peso,
}) {
  return PreviousSetCandidate(
    workoutId: workoutId,
    fecha: fecha,
    performance: PreviousSetPerformance(
      numSet: numSet,
      reps: reps,
      peso: peso,
    ),
  );
}

void main() {
  group('selectMostRecentWorkoutSets', () {
    test('lista vacía → []', () {
      expect(selectMostRecentWorkoutSets(const []), isEmpty);
    });

    test('un solo workout → sus sets ordenados por num_set', () {
      final fecha = DateTime(2026, 6, 20);
      final result = selectMostRecentWorkoutSets([
        _candidate(1, fecha, 2, reps: 6, peso: 65),
        _candidate(1, fecha, 1, reps: 8, peso: 60),
      ]);

      expect(result.map((p) => p.numSet), [1, 2]);
      expect(result.first.peso, 60);
      expect(result.last.peso, 65);
    });

    test('varios workouts con fechas distintas → solo los del más reciente', () {
      final viejo = DateTime(2026, 6, 10);
      final reciente = DateTime(2026, 6, 18);
      final result = selectMostRecentWorkoutSets([
        // Sesión antigua (no debe salir).
        _candidate(1, viejo, 1, reps: 10, peso: 50),
        _candidate(1, viejo, 2, reps: 10, peso: 50),
        // Sesión más reciente (sale, ordenada por num_set).
        _candidate(2, reciente, 2, reps: 6, peso: 72),
        _candidate(2, reciente, 1, reps: 8, peso: 70),
      ]);

      expect(result.length, 2);
      expect(result.map((p) => p.numSet), [1, 2]);
      expect(result.first.peso, 70);
      expect(result.last.peso, 72);
    });

    test('empate de fecha → desempata por el mayor workoutId', () {
      final fecha = DateTime(2026, 6, 21);
      final result = selectMostRecentWorkoutSets([
        _candidate(5, fecha, 1, reps: 5, peso: 80),
        _candidate(9, fecha, 1, reps: 7, peso: 90),
      ]);

      expect(result.length, 1);
      expect(result.single.peso, 90);
      expect(result.single.reps, 7);
    });
  });
}
