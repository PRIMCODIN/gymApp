import '../domain/entities/workout_detail.dart';

/// Funciones puras de cálculo del historial de entrenos. Sin Flutter ni Supabase
/// para poder testearlas. Operan sobre filas planas de `workout_sets` ya leídas o
/// sobre la estructura de dominio ya construida. Mismo precedente que
/// `workout_previous_parser.dart` (helpers puros en la capa de datos).

/// Volumen total (kg) de una lista de sets: suma de `peso * reps` SOLO de los sets
/// con `completado == true` y con `peso`/`reps` no nulos. Los sets sin completar o
/// con datos a medias no suman.
double computeTotalVolume(Iterable<WorkoutDetailSet> sets) {
  var total = 0.0;
  for (final set in sets) {
    if (!set.completado) continue;
    final reps = set.reps;
    final peso = set.peso;
    if (reps == null || peso == null) continue;
    total += peso * reps;
  }
  return total;
}

/// Agrupa filas planas de `workout_sets` en la estructura ejercicios -> sets. Cada
/// ejercicio se identifica por `orden_ejercicio` (con el snapshot de
/// `nombre_ejercicio`/`grupo_muscular`); los ejercicios se ordenan por
/// `orden_ejercicio` y sus sets por `num_set`. Función pura sobre las filas leídas.
List<WorkoutDetailExercise> groupSetsIntoExercises(
  List<Map<String, dynamic>> rows,
) {
  final byOrden = <int, _ExerciseAccumulator>{};

  for (final row in rows) {
    final orden = _readInt(row['orden_ejercicio']) ?? 0;
    final acc = byOrden.putIfAbsent(
      orden,
      () => _ExerciseAccumulator(
        nombreEjercicio: (row['nombre_ejercicio'] as String?) ?? '',
        grupoMuscular: (row['grupo_muscular'] as String?) ?? '',
        orden: orden,
      ),
    );
    acc.sets.add(
      WorkoutDetailSet(
        numSet: _readInt(row['num_set']) ?? 0,
        reps: _readInt(row['reps']),
        peso: _readDouble(row['peso']),
        completado: (row['completado'] as bool?) ?? false,
      ),
    );
  }

  final exercises = byOrden.values.map((acc) => acc.toEntity()).toList()
    ..sort((a, b) => a.orden.compareTo(b.orden));
  return exercises;
}

/// Acumulador mutable interno mientras se agrupan las filas de un ejercicio.
class _ExerciseAccumulator {
  _ExerciseAccumulator({
    required this.nombreEjercicio,
    required this.grupoMuscular,
    required this.orden,
  });

  final String nombreEjercicio;
  final String grupoMuscular;
  final int orden;
  final List<WorkoutDetailSet> sets = [];

  WorkoutDetailExercise toEntity() {
    sets.sort((a, b) => a.numSet.compareTo(b.numSet));
    return WorkoutDetailExercise(
      nombreEjercicio: nombreEjercicio,
      grupoMuscular: grupoMuscular,
      orden: orden,
      sets: List.unmodifiable(sets),
    );
  }
}

/// Lee un entero tolerando null y representación como texto.
int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Lee un numérico (`numeric` puede venir como texto, incl. coma decimal).
double? _readDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}
