import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP compartido para llamar a servicios externos (p. ej. los webhooks
/// de n8n). Se expone vía Riverpod en vez de instanciarlo en cada datasource, así
/// se reutiliza la conexión y es fácil de sustituir por un mock en tests.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});
