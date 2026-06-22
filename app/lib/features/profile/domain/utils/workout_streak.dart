/// Lógica pura de la racha semanal de entreno (sin I/O ni Supabase). Se aísla
/// aquí para poder testearla de forma determinista inyectando [now].
///
/// Definición de racha (semana ISO lunes–domingo):
/// - Una semana "cuenta" si tiene **≥3 workouts finalizados** (sesiones, no días
///   distintos: 3 sesiones el mismo día también cumplen).
/// - La racha es el nº de semanas consecutivas cumplidas hacia atrás.
/// - La **semana en curso** (la que contiene `now`) nunca baja la racha: aún no
///   ha terminado, así que se le da clemencia. Si ya llega a 3, suma; si aún no,
///   es neutra (no rompe; la racha se mide desde la semana anterior).
/// - Cualquier semana **ya cerrada** hacia atrás con <3 sí rompe la racha.
const int _weeklyTarget = 3;

/// Devuelve la racha actual de semanas consecutivas con ≥3 entrenos finalizados.
///
/// [finishedWorkoutDates] son las fechas de los workouts finalizados del usuario
/// (una por sesión; los duplicados de la misma semana cuentan por separado).
/// [now] es inyectable para tests deterministas; solo se recurre a
/// `DateTime.now()` cuando es `null`. La función nunca lo llama de otro modo.
int currentStreak(List<DateTime> finishedWorkoutDates, {DateTime? now}) {
  final reference = now ?? DateTime.now();

  // Sesiones agrupadas por inicio de su semana ISO (cuenta sesiones, no días).
  final sessionsPerWeek = <DateTime, int>{};
  for (final date in finishedWorkoutDates) {
    final weekStart = _isoWeekStart(date);
    sessionsPerWeek[weekStart] = (sessionsPerWeek[weekStart] ?? 0) + 1;
  }

  final currentWeekStart = _isoWeekStart(reference);
  final currentCount = sessionsPerWeek[currentWeekStart] ?? 0;

  // La semana en curso solo puede sumar (si ya cumple), nunca rompe: aún no ha
  // terminado. Si no cumple es neutra y la racha se mide desde la anterior.
  var streak = currentCount >= _weeklyTarget ? 1 : 0;

  // A partir de aquí, semanas YA CERRADAS hacia atrás: una con <3 sí rompe.
  // Empezamos siempre en la semana anterior a la actual, paramos al primer hueco.
  var week = _previousWeek(currentWeekStart);
  while ((sessionsPerWeek[week] ?? 0) >= _weeklyTarget) {
    streak++;
    week = _previousWeek(week);
  }

  return streak;
}

/// Inicio (lunes 00:00 local) de la semana ISO que contiene [date]. Se construye
/// vía el constructor de `DateTime` (no `subtract(Duration)`) para no arrastrar
/// el desfase de hora de los cambios de horario de verano.
DateTime _isoWeekStart(DateTime date) {
  // weekday: 1 = lunes ... 7 = domingo.
  return DateTime(date.year, date.month, date.day - (date.weekday - 1));
}

/// Inicio de la semana anterior a [weekStart] (que debe ser un lunes 00:00).
DateTime _previousWeek(DateTime weekStart) {
  return DateTime(weekStart.year, weekStart.month, weekStart.day - 7);
}
