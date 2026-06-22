/// Resolución del nombre mostrado del usuario, compartida por Perfil e Inicio.
///
/// Punto único de verdad: el nombre real (trimmeado) si existe, o `'Sin nombre'`
/// como fallback. La inicial del email NO se usa aquí (eso solo alimenta las
/// iniciales del avatar en Perfil); así Inicio y Perfil nunca divergen.
String resolveDisplayName(String? name) {
  final trimmed = name?.trim() ?? '';
  return trimmed.isNotEmpty ? trimmed : 'Sin nombre';
}
