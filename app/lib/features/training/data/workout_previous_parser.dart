import '../domain/entities/previous_set_performance.dart';

/// Un set candidato para la columna PREVIOUS, con la metadata de su sesión.
///
/// El datasource construye una lista de estos a partir del join
/// `workout_sets` + `workouts` (filtrado por `exercise_id` y `finalizado=true`).
/// El emparejado de "qué sesión es la más reciente" lo decide
/// [selectMostRecentWorkoutSets], que es función pura y testeable.
class PreviousSetCandidate {
  const PreviousSetCandidate({
    required this.workoutId,
    required this.fecha,
    required this.performance,
  });

  final int workoutId;
  final DateTime fecha;
  final PreviousSetPerformance performance;
}

/// Elige, de entre [candidates] (todos del mismo ejercicio, de sesiones
/// finalizadas), los sets de la sesión MÁS RECIENTE y los devuelve ordenados por
/// `num_set`.
///
/// Criterio: mayor `fecha`; si dos sesiones comparten fecha, desempata por el
/// mayor `workoutId` (el id es monótono creciente, así que equivale a la creada
/// más tarde). Lista vacía → `[]` (no hay histórico). Función pura.
List<PreviousSetPerformance> selectMostRecentWorkoutSets(
  List<PreviousSetCandidate> candidates,
) {
  if (candidates.isEmpty) return const [];

  // Identifica el workout más reciente (fecha desc, luego workoutId desc).
  var bestWorkoutId = candidates.first.workoutId;
  var bestFecha = candidates.first.fecha;
  for (final candidate in candidates.skip(1)) {
    final isLaterDate = candidate.fecha.isAfter(bestFecha);
    final isSameDateNewerId = candidate.fecha.isAtSameMomentAs(bestFecha) &&
        candidate.workoutId > bestWorkoutId;
    if (isLaterDate || isSameDateNewerId) {
      bestWorkoutId = candidate.workoutId;
      bestFecha = candidate.fecha;
    }
  }

  // Toma solo los sets de esa sesión y ordénalos por num_set ascendente.
  final sets = candidates
      .where((candidate) => candidate.workoutId == bestWorkoutId)
      .map((candidate) => candidate.performance)
      .toList()
    ..sort((a, b) => a.numSet.compareTo(b.numSet));

  return sets;
}
