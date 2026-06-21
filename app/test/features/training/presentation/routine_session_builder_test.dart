import 'package:app/features/training/domain/entities/routine.dart';
import 'package:app/features/training/domain/entities/routine_exercise_item.dart';
import 'package:app/features/training/presentation/utils/routine_session_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Contador simple para inyectar uids deterministas en los tests.
  int Function() counter() {
    var seq = 0;
    return () => ++seq;
  }

  RoutineExerciseItem item({
    int? exerciseId = 1,
    String nombre = 'Press banca',
    String grupo = 'pecho',
    required int orden,
    required int series,
  }) {
    return RoutineExerciseItem(
      exerciseId: exerciseId,
      nombreEjercicio: nombre,
      grupoMuscular: grupo,
      orden: orden,
      seriesObjetivo: series,
    );
  }

  group('routineToActiveExercises', () {
    test(
      'N items generan N ejercicios con series_objetivo sets vacíos en orden',
      () {
        final routine = Routine(
          id: 1,
          nombre: 'Empuje',
          items: [
            item(nombre: 'Press banca', orden: 1, series: 3),
            item(nombre: 'Press militar', orden: 2, series: 2),
          ],
        );

        final exercises = routineToActiveExercises(routine, counter());

        expect(exercises.length, 2);

        // Orden secuencial 1..n y snapshot de nombre/grupo conservado.
        expect(exercises[0].orden, 1);
        expect(exercises[0].nombre, 'Press banca');
        expect(exercises[1].orden, 2);
        expect(exercises[1].nombre, 'Press militar');

        // Nº de sets = series_objetivo, numerados 1..n.
        expect(exercises[0].sets.length, 3);
        expect(exercises[1].sets.length, 2);
        expect(exercises[0].sets.map((s) => s.numSet), [1, 2, 3]);
        expect(exercises[1].sets.map((s) => s.numSet), [1, 2]);
      },
    );

    test('todos los sets precargados están vacíos (reps/peso null, sin marcar)', () {
      final routine = Routine(
        id: 1,
        nombre: 'Pierna',
        items: [item(nombre: 'Sentadilla', orden: 1, series: 4)],
      );

      final sets = routineToActiveExercises(routine, counter()).single.sets;

      for (final set in sets) {
        expect(set.reps, isNull);
        expect(set.peso, isNull);
        expect(set.completado, isFalse);
      }
    });

    test('los uids de los sets son únicos (vienen del generador)', () {
      final routine = Routine(
        id: 1,
        nombre: 'Full body',
        items: [
          item(nombre: 'A', orden: 1, series: 2),
          item(nombre: 'B', orden: 2, series: 2),
        ],
      );

      final exercises = routineToActiveExercises(routine, counter());
      final uids = [
        for (final e in exercises) ...e.sets.map((s) => s.uid),
      ];

      expect(uids.toSet().length, uids.length);
      expect(uids, [1, 2, 3, 4]);
    });

    test('exercise_id null cae a 0 (ejercicio borrado del catálogo)', () {
      final routine = Routine(
        id: 1,
        nombre: 'Vieja',
        items: [item(exerciseId: null, nombre: 'X', grupo: '', orden: 1, series: 1)],
      );

      final exercise = routineToActiveExercises(routine, counter()).single;
      expect(exercise.exerciseId, 0);
      expect(exercise.grupoMuscular, '');
    });

    test('rutina sin items → lista vacía', () {
      const routine = Routine(id: 1, nombre: 'Vacía');
      expect(routineToActiveExercises(routine, counter()), isEmpty);
    });
  });

  group('reorderRoutineItems', () {
    List<RoutineExerciseItem> base() => [
          item(nombre: 'A', orden: 1, series: 3),
          item(nombre: 'B', orden: 2, series: 3),
          item(nombre: 'C', orden: 3, series: 3),
        ];

    test('mover abajo intercambia y renumera el orden', () {
      final result = reorderRoutineItems(base(), 0, 1);
      expect(result.map((e) => e.nombreEjercicio), ['B', 'A', 'C']);
      expect(result.map((e) => e.orden), [1, 2, 3]);
    });

    test('mover arriba intercambia y renumera el orden', () {
      final result = reorderRoutineItems(base(), 2, -1);
      expect(result.map((e) => e.nombreEjercicio), ['A', 'C', 'B']);
      expect(result.map((e) => e.orden), [1, 2, 3]);
    });

    test('primer item hacia arriba: sin cambios, orden intacto', () {
      final result = reorderRoutineItems(base(), 0, -1);
      expect(result.map((e) => e.nombreEjercicio), ['A', 'B', 'C']);
      expect(result.map((e) => e.orden), [1, 2, 3]);
    });

    test('último item hacia abajo: sin cambios, orden intacto', () {
      final result = reorderRoutineItems(base(), 2, 1);
      expect(result.map((e) => e.nombreEjercicio), ['A', 'B', 'C']);
      expect(result.map((e) => e.orden), [1, 2, 3]);
    });
  });
}
