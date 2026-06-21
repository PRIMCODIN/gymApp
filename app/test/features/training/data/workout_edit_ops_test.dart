import 'package:app/features/training/data/workout_edit_ops.dart';
import 'package:app/features/training/domain/entities/workout_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('removeSetAndRenumber', () {
    test('renumera num_set contiguo tras borrar uno intermedio', () {
      final sets = [
        const WorkoutDetailSet(numSet: 1, completado: true, reps: 10, peso: 50),
        const WorkoutDetailSet(numSet: 2, completado: true, reps: 8, peso: 60),
        const WorkoutDetailSet(numSet: 3, completado: false, reps: 6, peso: 70),
      ];

      final result = removeSetAndRenumber(sets, 1);

      expect(result.map((s) => s.numSet), [1, 2]);
      // El que era el 3º conserva sus datos y pasa a num_set 2.
      expect(result[1].reps, 6);
      expect(result[1].peso, 70);
      expect(result[1].completado, isFalse);
    });

    test('preserva uid, rpe y completado de los restantes', () {
      final sets = [
        const WorkoutDetailSet(
          numSet: 1,
          completado: true,
          reps: 10,
          peso: 50,
          rpe: 8,
          uid: 11,
        ),
        const WorkoutDetailSet(numSet: 2, completado: true, reps: 8, peso: 60),
      ];

      final result = removeSetAndRenumber(sets, 1);

      expect(result.single.uid, 11);
      expect(result.single.rpe, 8);
      expect(result.single.numSet, 1);
    });

    test('índice fuera de rango devuelve copia sin cambios', () {
      final sets = [
        const WorkoutDetailSet(numSet: 1, completado: true, reps: 10, peso: 50),
      ];
      final result = removeSetAndRenumber(sets, 5);
      expect(result.length, 1);
      expect(result[0].numSet, 1);
    });
  });

  group('removeExerciseAndRenumber', () {
    List<WorkoutDetailExercise> sample() => [
          const WorkoutDetailExercise(
            nombreEjercicio: 'Sentadilla',
            grupoMuscular: 'cuadriceps',
            orden: 1,
            sets: [],
          ),
          const WorkoutDetailExercise(
            nombreEjercicio: 'Press banca',
            grupoMuscular: 'pecho',
            orden: 2,
            sets: [],
          ),
          const WorkoutDetailExercise(
            nombreEjercicio: 'Remo',
            grupoMuscular: 'espalda',
            orden: 3,
            sets: [],
          ),
        ];

    test('renumera orden contiguo tras borrar el primero', () {
      final result = removeExerciseAndRenumber(sample(), 0);

      expect(result.map((e) => e.orden), [1, 2]);
      expect(result.map((e) => e.nombreEjercicio), ['Press banca', 'Remo']);
    });

    test('índice fuera de rango devuelve copia sin cambios', () {
      final result = removeExerciseAndRenumber(sample(), 9);
      expect(result.map((e) => e.orden), [1, 2, 3]);
    });
  });

  group('assignSetUids', () {
    test('asigna uids únicos y secuenciales a todos los sets', () {
      final exercises = [
        const WorkoutDetailExercise(
          nombreEjercicio: 'Sentadilla',
          grupoMuscular: 'cuadriceps',
          orden: 1,
          sets: [
            WorkoutDetailSet(numSet: 1, completado: true, reps: 5, peso: 100),
            WorkoutDetailSet(numSet: 2, completado: true, reps: 5, peso: 100),
          ],
        ),
        const WorkoutDetailExercise(
          nombreEjercicio: 'Press banca',
          grupoMuscular: 'pecho',
          orden: 2,
          sets: [
            WorkoutDetailSet(numSet: 1, completado: true, reps: 8, peso: 60),
          ],
        ),
      ];

      final result = assignSetUids(exercises);
      final uids = [
        for (final e in result)
          for (final s in e.sets) s.uid,
      ];

      expect(uids, [1, 2, 3]);
    });
  });
}
