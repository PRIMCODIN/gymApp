// Etiquetas legibles en español para el día de la semana de una rutina.
//
// La BD guarda `dia_semana` como smallint 1-7 (1 = lunes ... 7 = domingo,
// estándar ISO) y nullable (sin día). La UI nunca muestra el número crudo: pasa
// siempre por `weekdayLabel`.

/// Días seleccionables en el editor, en orden de presentación (lunes → domingo).
const List<int> kWeekdays = <int>[1, 2, 3, 4, 5, 6, 7];

/// Etiquetas por número de día (1 = lunes ... 7 = domingo).
const Map<int, String> _weekdayLabels = <int, String>{
  1: 'Lunes',
  2: 'Martes',
  3: 'Miércoles',
  4: 'Jueves',
  5: 'Viernes',
  6: 'Sábado',
  7: 'Domingo',
};

/// Etiqueta legible de un día de la semana. `null` o fuera de rango (1-7) →
/// "Sin día", para que la UI nunca se rompa con datos inesperados.
String weekdayLabel(int? dia) {
  if (dia == null) return 'Sin día';
  return _weekdayLabels[dia] ?? 'Sin día';
}
