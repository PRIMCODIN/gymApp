// Funciones puras para construir el calendario mensual del historial sin ninguna
// dependencia externa (ni de calendario ni de fechas). Date local, no UTC. Se
// testean de forma aislada.

/// Nº de días del mes [month] (1-12) del año [year]. El día 0 del mes siguiente
/// es el último del mes actual.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Día de la semana del día 1 del mes (ISO: 1 = lunes ... 7 = domingo).
int firstWeekdayOfMonth(int year, int month) => DateTime(year, month, 1).weekday;

/// Rango [primer día, último día] del mes, a medianoche local.
({DateTime first, DateTime last}) monthRange(int year, int month) => (
      first: DateTime(year, month, 1),
      last: DateTime(year, month, daysInMonth(year, month)),
    );

/// `true` si [a] y [b] son el mismo día (ignora la hora).
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Etiqueta "mes año" en español, p.ej. "junio 2026". Mes fuera de rango → solo
/// el año (la UI nunca se rompe).
String monthYearLabel(int year, int month) {
  final name = (month >= 1 && month <= 12) ? _monthNames[month - 1] : '';
  return name.isEmpty ? '$year' : '$name $year';
}

/// Iniciales de los días de la semana en orden de presentación (lunes → domingo).
const List<String> kWeekdayInitials = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

/// Nombres de los meses en español (enero = índice 0).
const List<String> _monthNames = <String>[
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
