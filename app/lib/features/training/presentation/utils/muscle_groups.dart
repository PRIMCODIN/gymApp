// Lista cerrada de grupos musculares y sus etiquetas legibles en español.
//
// Los valores (claves) deben coincidir EXACTAMENTE con los del seed de
// `db/schema_entreno.sql` (columna `grupo_muscular`). La UI los muestra siempre a
// través de `muscleGroupLabel`; nunca se enseña la clave cruda.

/// Claves de grupo muscular en el orden de presentación (sigue el seed).
const List<String> kMuscleGroups = <String>[
  'pecho',
  'espalda',
  'dorsales',
  'trapecio',
  'hombro_anterior',
  'hombro_lateral',
  'hombro_posterior',
  'biceps',
  'triceps',
  'antebrazo',
  'cuadriceps',
  'isquios',
  'gluteo',
  'gemelo',
  'abductores',
  'aductores',
  'abdomen',
  'lumbar',
  'full_body',
];

/// Etiquetas legibles por clave. Mantener en sync con [kMuscleGroups].
const Map<String, String> _muscleGroupLabels = <String, String>{
  'pecho': 'Pecho',
  'espalda': 'Espalda',
  'dorsales': 'Dorsales',
  'trapecio': 'Trapecio',
  'hombro_anterior': 'Hombro (anterior)',
  'hombro_lateral': 'Hombro (lateral)',
  'hombro_posterior': 'Hombro (posterior)',
  'biceps': 'Bíceps',
  'triceps': 'Tríceps',
  'antebrazo': 'Antebrazo',
  'cuadriceps': 'Cuádriceps',
  'isquios': 'Isquios',
  'gluteo': 'Glúteo',
  'gemelo': 'Gemelo',
  'abductores': 'Abductores',
  'aductores': 'Aductores',
  'abdomen': 'Abdomen',
  'lumbar': 'Lumbar',
  'full_body': 'Full body',
};

/// Etiqueta legible de un grupo muscular. Si la clave no está en el mapa (datos
/// de la BD ampliados sin tocar la app), cae a un formato capitalizado y con
/// espacios para no romper la UI.
String muscleGroupLabel(String key) {
  final label = _muscleGroupLabels[key];
  if (label != null) return label;
  return _humanize(key);
}

/// Convierte una clave desconocida (`snake_case`) en algo presentable
/// (`Snake case`). Fallback defensivo: nunca debería ejecutarse con el seed
/// actual.
String _humanize(String key) {
  if (key.isEmpty) return key;
  final spaced = key.replaceAll('_', ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
