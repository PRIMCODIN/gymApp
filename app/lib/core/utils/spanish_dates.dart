// Nombres de fechas en español, sin dependencias externas (`intl`).
//
// El proyecto formatea español a mano (ver `specs/design-system.md` y el patrón
// ya estrenado en training). Este archivo es la fuente de verdad compartida de los
// nombres de mes; `calendar_month.dart` (training) mantiene su propia copia privada
// por ahora y debería migrar aquí cuando se toque esa zona.

/// Nombres de los meses en español (enero = índice 0), en minúscula.
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

/// Nombres de los días de la semana en español, minúscula e índice ISO
/// (1 = lunes ... 7 = domingo).
const List<String> _weekdayNames = <String>[
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// Nombre del mes en español. [month] en rango 1-12; fuera de rango → cadena vacía
/// (la UI nunca se rompe).
String spanishMonthName(int month) {
  if (month < 1 || month > 12) return '';
  return _monthNames[month - 1];
}

/// Nombre del día de la semana en español. [weekday] en rango ISO 1-7 (como
/// `DateTime.weekday`); fuera de rango → cadena vacía.
String spanishWeekdayName(int weekday) {
  if (weekday < 1 || weekday > 7) return '';
  return _weekdayNames[weekday - 1];
}
