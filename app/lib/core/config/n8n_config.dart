/// Configuración del orquestador n8n.
///
/// La ESCRITURA pasa por n8n (ver `specs/architecture.md`): Flutter hace un POST
/// a un webhook y n8n se encarga de la lógica (y, en fases futuras, la IA). Aquí
/// vive, en un único sitio, la URL base y los paths de los webhooks que usa la app.
class N8nConfig {
  const N8nConfig._();

  /// URL base donde corre n8n. Cambia según dónde se ejecute la app:
  ///   - Flutter web/desktop en la misma máquina → `http://localhost:5678`
  ///   - Emulador Android (accede al host por una IP especial) → `http://10.0.2.2:5678`
  ///   - Móvil físico (debe ver el PC en la LAN) → `http://IP-DEL-PC:5678`
  /// Cambia solo este valor para apuntar a otro entorno.
  static const String baseUrl = 'http://localhost:5678';

  /// Path del webhook que estima kcal + macros a partir de la descripción.
  // TODO: sustituir por el path REAL del nodo Webhook de n8n (verifícalo en el
  // propio nodo Webhook del workflow de estimación).
  static const String estimateMealPath = '/webhook/registrar-comida';

  /// URI completa del webhook de estimación de comidas.
  static Uri estimateMealUri() => Uri.parse('$baseUrl$estimateMealPath');
}
