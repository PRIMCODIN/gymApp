// Formato legible (español) del resumen de un workout en el historial.

/// Línea de resumen "N ejercicios · M sets · X kg".
String formatSummaryLine(int numEjercicios, int numSets, double volumen) {
  final ejercicios = numEjercicios == 1
      ? '1 ejercicio'
      : '$numEjercicios ejercicios';
  final sets = numSets == 1 ? '1 set' : '$numSets sets';
  return '$ejercicios · $sets · ${formatVolume(volumen)}';
}

/// Volumen en kg: sin decimales si es entero; con un decimal en otro caso.
String formatVolume(double volumen) {
  if (volumen == volumen.roundToDouble()) return '${volumen.toInt()} kg';
  return '${volumen.toStringAsFixed(1)} kg';
}
