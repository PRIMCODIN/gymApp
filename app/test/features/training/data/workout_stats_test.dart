import 'package:app/features/training/data/workout_stats.dart';
import 'package:app/features/training/domain/entities/workout_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeTotalVolume', () {
    test('suma solo los sets completados con reps y peso', () {
      final sets = [
        const WorkoutDetailSet(numSet: 1, completado: true, reps: 10, peso: 50),
        const WorkoutDetailSet(numSet: 2, completado: true, reps: 8, peso: 60),
      ];
      // 10*50 + 8*60 = 500 + 480 = 980
      expect(computeTotalVolume(sets), 980);
    });

    test('los sets sin completar no suman', () {
      final sets = [
        const WorkoutDetailSet(numSet: 1, completado: true, reps: 10, peso: 50),
        const WorkoutDetailSet(numSet: 2, completado: false, reps: 8, peso: 60),
      ];
      expect(computeTotalVolume(sets), 500);
    });

    test('los sets con reps o peso null no suman', () {
      final sets = [
        const WorkoutDetailSet(numSet: 1, completado: true, reps: null, peso: 50),
        const WorkoutDetailSet(numSet: 2, completado: true, reps: 8, peso: null),
        const WorkoutDetailSet(numSet: 3, completado: true, reps: 5, peso: 20),
      ];
      expect(computeTotalVolume(sets), 100);
    });

    test('lista vacía → 0', () {
      expect(computeTotalVolume(const []), 0);
    });
  });

  group('groupSetsIntoExercises', () {
    test('agrupa por orden_ejercicio y ordena ejercicios y sets', () {
      final rows = <Map<String, dynamic>>[
        {
          'orden_ejercicio': 2,
          'nombre_ejercicio': 'Press banca',
          'grupo_muscular': 'pecho',
          'num_set': 2,
          'reps': 8,
          'peso': 60,
          'completado': true,
        },
        {
          'orden_ejercicio': 1,
          'nombre_ejercicio': 'Sentadilla',
          'grupo_muscular': 'cuadriceps',
          'num_set': 1,
          'reps': 5,
          'peso': 100,
          'completado': true,
        },
        {
          'orden_ejercicio': 2,
          'nombre_ejercicio': 'Press banca',
          'grupo_muscular': 'pecho',
          'num_set': 1,
          'reps': 10,
          'peso': 50,
          'completado': true,
        },
      ];

      final exercises = groupSetsIntoExercises(rows);

      // Dos ejercicios distintos, ordenados por orden_ejercicio (1, 2).
      expect(exercises.length, 2);
      expect(exercises[0].nombreEjercicio, 'Sentadilla');
      expect(exercises[1].nombreEjercicio, 'Press banca');

      // Los sets del 2º ejercicio quedan ordenados por num_set (1, 2).
      final pressSets = exercises[1].sets;
      expect(pressSets.length, 2);
      expect(pressSets[0].numSet, 1);
      expect(pressSets[1].numSet, 2);
      expect(pressSets[0].peso, 50);
    });

    test('lee reps/peso como texto y completado ausente como false', () {
      final rows = <Map<String, dynamic>>[
        {
          'orden_ejercicio': 1,
          'nombre_ejercicio': 'Curl',
          'grupo_muscular': 'biceps',
          'num_set': 1,
          'reps': '12',
          'peso': '15.5',
          // 'completado' ausente
        },
      ];

      final exercises = groupSetsIntoExercises(rows);
      final set = exercises.single.sets.single;
      expect(set.reps, 12);
      expect(set.peso, 15.5);
      expect(set.completado, isFalse);
    });

    test('lista vacía → sin ejercicios', () {
      expect(groupSetsIntoExercises(const []), isEmpty);
    });
  });
}
