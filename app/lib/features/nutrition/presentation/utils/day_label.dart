/// Etiqueta legible en español para una fecha relativa a [today].
///
/// Función pura (sin Flutter ni locale del sistema) para poder testearla. Reglas:
/// el mismo día → "Hoy"; el día anterior → "Ayer"; cualquier otro → un formato
/// corto tipo "mar 17 jun" (día de semana + día + mes, abreviados en español).
/// Compara solo la parte de fecha (ignora horas).
String formatDayLabel(DateTime day, DateTime today) {
  final d = DateTime(day.year, day.month, day.day);
  final t = DateTime(today.year, today.month, today.day);
  final diff = d.difference(t).inDays;

  if (diff == 0) return 'Hoy';
  if (diff == -1) return 'Ayer';

  final weekday = _weekdays[d.weekday - 1];
  final month = _months[d.month - 1];
  return '$weekday ${d.day} $month';
}

/// Abreviaturas de los días de la semana (lunes = índice 0).
const List<String> _weekdays = [
  'lun',
  'mar',
  'mié',
  'jue',
  'vie',
  'sáb',
  'dom',
];

/// Abreviaturas de los meses (enero = índice 0).
const List<String> _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
