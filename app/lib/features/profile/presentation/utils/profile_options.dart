// Listas cerradas de los enums de texto del perfil y sus etiquetas legibles en
// español. Mismo patrón que `training/.../utils/muscle_groups.dart`.
//
// Las claves (valores) deben coincidir EXACTAMENTE con los CHECK de la tabla
// `profiles` en BD (ver `specs/perfil.md`): se envían tal cual al guardar. La UI
// muestra siempre la etiqueta, nunca la clave cruda.

/// Sexo: claves de BD en orden de presentación.
const List<String> kSexes = <String>['hombre', 'mujer'];

const Map<String, String> _sexLabels = <String, String>{
  'hombre': 'Hombre',
  'mujer': 'Mujer',
};

/// Etiqueta legible de un sexo (o la clave capitalizada si fuera desconocida).
String sexLabel(String key) => _sexLabels[key] ?? _humanize(key);

/// Nivel de actividad: claves de BD en orden de menor a mayor.
const List<String> kActivityLevels = <String>[
  'sedentario',
  'ligero',
  'moderado',
  'activo',
  'muy_activo',
];

const Map<String, String> _activityLevelLabels = <String, String>{
  'sedentario': 'Sedentario',
  'ligero': 'Ligero',
  'moderado': 'Moderado',
  'activo': 'Activo',
  'muy_activo': 'Muy activo',
};

/// Etiqueta legible de un nivel de actividad.
String activityLevelLabel(String key) =>
    _activityLevelLabels[key] ?? _humanize(key);

/// Objetivo: claves de BD en orden de presentación.
const List<String> kGoals = <String>['perder', 'mantener', 'ganar'];

const Map<String, String> _goalLabels = <String, String>{
  'perder': 'Perder',
  'mantener': 'Mantener',
  'ganar': 'Ganar',
};

/// Etiqueta legible de un objetivo.
String goalLabel(String key) => _goalLabels[key] ?? _humanize(key);

/// Convierte una clave desconocida (`snake_case`) en algo presentable
/// (`Snake case`). Fallback defensivo: no debería ejecutarse con los CHECK
/// actuales.
String _humanize(String key) {
  if (key.isEmpty) return key;
  final spaced = key.replaceAll('_', ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
