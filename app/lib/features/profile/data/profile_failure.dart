import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de la feature de perfil con un mensaje legible en español para la UI.
///
/// Centraliza la regla "nada de errores silenciosos" (`specs/conventions.md`):
/// los fallos de red o de Supabase se traducen aquí a un texto que el usuario
/// entiende. Espejo de `nutrition/data/nutrition_failure.dart`.
class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  @override
  String toString() => 'ProfileFailure: $message';
}

/// Traduce un error cualquiera a un [ProfileFailure] con mensaje en español.
/// El perfil solo habla con Supabase (lectura/guardado directos); aun así se
/// cubren los fallos de red genéricos. Si no se reconoce, devuelve un mensaje
/// genérico pero nunca lo silencia.
ProfileFailure mapProfileError(Object error) {
  if (error is ProfileFailure) return error;

  // Sin conexión: el host no responde o no hay red.
  if (error is SocketException) {
    return const ProfileFailure(
      'No hay conexión. Revisa tu red e inténtalo de nuevo.',
    );
  }

  // La petición tardó demasiado en responder.
  if (error is TimeoutException) {
    return const ProfileFailure(
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
    );
  }

  // Error de Supabase al leer/guardar (RLS, columna, CHECK, conexión...).
  if (error is PostgrestException) {
    return ProfileFailure('No se pudo guardar tu perfil: ${error.message}');
  }

  return const ProfileFailure(
    'Ha ocurrido un error inesperado. Inténtalo de nuevo.',
  );
}
