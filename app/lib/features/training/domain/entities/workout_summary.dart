/// Resumen de lectura de un workout finalizado, para las tarjetas de la lista de
/// un día del historial. Entidad pura de dominio. Inmutable.
///
/// Los conteos y el volumen ([numEjercicios], [numSets], [volumenTotal]) se
/// calculan en la capa de datos a partir de los `workout_sets` con funciones puras
/// (`data/workout_stats.dart`); aquí solo se transportan ya resueltos.
class WorkoutSummary {
  const WorkoutSummary({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.numEjercicios,
    required this.numSets,
    required this.volumenTotal,
    this.duracionS,
  });

  final int id;

  final String nombre;

  /// Fecha (local) del workout, sin componente horario.
  final DateTime fecha;

  /// Duración en segundos; `null` si no se registró.
  final int? duracionS;

  final int numEjercicios;

  final int numSets;

  /// Volumen total en kg (suma de `peso * reps` de los sets completados).
  final double volumenTotal;
}
