import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de la feature de nutrición con un mensaje legible en español para la UI.
///
/// Centraliza la regla "nada de errores silenciosos" (`specs/conventions.md`):
/// los fallos de red, de n8n o de Supabase se traducen aquí a un texto que el
/// usuario entiende. Espejo de `core/errors/auth_failure.dart`.
class NutritionFailure implements Exception {
  const NutritionFailure(this.message);

  final String message;

  @override
  String toString() => 'NutritionFailure: $message';
}

/// Traduce un error cualquiera a un [NutritionFailure] con mensaje en español.
/// Cubre los fallos del flujo estimar (n8n vía HTTP) y guardar (Supabase). Si no
/// se reconoce, devuelve un mensaje genérico pero nunca lo silencia.
NutritionFailure mapNutritionError(Object error) {
  if (error is NutritionFailure) return error;

  // Sin conexión: el host no responde o no hay red.
  if (error is SocketException) {
    return const NutritionFailure(
      'No hay conexión. Revisa tu red e inténtalo de nuevo.',
    );
  }

  // El servidor (n8n) tardó demasiado en responder.
  if (error is TimeoutException) {
    return const NutritionFailure(
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
    );
  }

  // Respuesta de n8n con un cuerpo que no es el JSON esperado.
  if (error is FormatException) {
    return const NutritionFailure(
      'La respuesta del servidor no es válida.',
    );
  }

  // Error de Supabase al guardar (RLS, columna, conexión...).
  if (error is PostgrestException) {
    return NutritionFailure('No se pudo guardar la comida: ${error.message}');
  }

  return const NutritionFailure(
    'Ha ocurrido un error inesperado. Inténtalo de nuevo.',
  );
}
