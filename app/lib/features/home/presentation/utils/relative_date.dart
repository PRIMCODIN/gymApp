/// Etiqueta relativa en español de [date] respecto a [now] (o `DateTime.now()`).
///
/// Función pura (sin Flutter ni locale del sistema) para poder testearla de forma
/// determinista inyectando [now] —mismo patrón que `currentStreak`—. Compara solo
/// la parte de fecha (ignora horas): ayer a las 23h y hoy a la 1h son "ayer" y
/// "hoy", no "hace 2 horas".
///
/// Reglas:
/// - mismo día → "hoy".
/// - día anterior → "ayer".
/// - ≥2 días atrás → "hace N días".
/// - fechas futuras (no deberían darse para un último entreno) caen a "hoy" por
///   defensa, nunca rompen la UI.
String relativeDayLabel(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();

  // Solo parte de fecha: descarta horas/minutos para comparar por día natural.
  final thatDay = DateTime(date.year, date.month, date.day);
  final today = DateTime(reference.year, reference.month, reference.day);
  final diff = today.difference(thatDay).inDays;

  if (diff <= 0) return 'hoy';
  if (diff == 1) return 'ayer';
  return 'hace $diff días';
}
