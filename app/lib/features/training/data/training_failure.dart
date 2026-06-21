import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de la feature de Entreno con un mensaje legible en español para la UI.
///
/// Centraliza la regla "nada de errores silenciosos" (`specs/conventions.md`):
/// los fallos de red o de Supabase se traducen aquí a un texto que el usuario
/// entiende. Espejo de `features/nutrition/data/nutrition_failure.dart`.
class TrainingFailure implements Exception {
  const TrainingFailure(this.message);

  final String message;

  @override
  String toString() => 'TrainingFailure: $message';
}

/// Traduce un error cualquiera a un [TrainingFailure] con mensaje en español.
/// El entreno lee y escribe directo en Supabase (sin n8n), así que los fallos
/// esperados son de sesión, red o Postgrest (RLS, índice único...). Si no se
/// reconoce, devuelve un mensaje genérico pero nunca lo silencia.
TrainingFailure mapTrainingError(Object error) {
  if (error is TrainingFailure) return error;

  // Sin conexión: el host no responde o no hay red.
  if (error is SocketException) {
    return const TrainingFailure(
      'No hay conexión. Revisa tu red e inténtalo de nuevo.',
    );
  }

  // El servidor tardó demasiado en responder.
  if (error is TimeoutException) {
    return const TrainingFailure(
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
    );
  }

  // Error de Supabase (RLS, columna, conexión...). El código 23505 es violación
  // del índice único (nombre repetido para el mismo usuario): mensaje específico.
  if (error is PostgrestException) {
    if (error.code == '23505') {
      return const TrainingFailure('Ya tienes un ejercicio con ese nombre.');
    }
    return TrainingFailure(
      'No se pudo completar la operación: ${error.message}',
    );
  }

  return const TrainingFailure(
    'Ha ocurrido un error inesperado. Inténtalo de nuevo.',
  );
}
