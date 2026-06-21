import '../../domain/entities/previous_set_performance.dart';

/// Funciones puras de la sesión de entreno (cronómetro, duración y emparejado de
/// PREVIOUS). Sin Flutter ni Supabase, para poder testearlas. Mismo espíritu que
/// `features/nutrition/presentation/utils/day_label.dart`.

/// Segundos transcurridos entre [start] y [end]. Nunca negativo (un reloj que
/// retrocede o tiempos invertidos cuentan como 0).
int workoutDurationSeconds(DateTime start, DateTime end) {
  final seconds = end.difference(start).inSeconds;
  return seconds < 0 ? 0 : seconds;
}

/// Formatea una duración para el cronómetro en vivo: `mm:ss` hasta una hora y
/// `h:mm:ss` a partir de ahí. Negativos se tratan como cero.
String formatStopwatch(Duration elapsed) {
  final total = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$mm:$ss';
  }
  return '$mm:$ss';
}

/// Empareja la columna PREVIOUS por número de set: devuelve el rendimiento
/// anterior cuyo `numSet` coincide con [numSet], o `null` si no hay histórico
/// para ese set. Función pura.
PreviousSetPerformance? previousForSet(
  List<PreviousSetPerformance> previous,
  int numSet,
) {
  for (final performance in previous) {
    if (performance.numSet == numSet) return performance;
  }
  return null;
}
