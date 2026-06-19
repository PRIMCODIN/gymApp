import 'dart:async';
import 'dart:io';

import 'package:app/features/nutrition/data/nutrition_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapNutritionError', () {
    test('devuelve el mismo NutritionFailure sin envolverlo', () {
      const original = NutritionFailure('mensaje original');
      expect(mapNutritionError(original), same(original));
    });

    test('SocketException → mensaje de sin conexión', () {
      final failure = mapNutritionError(const SocketException('no route'));
      expect(failure.message, contains('conexión'));
    });

    test('TimeoutException → mensaje de tiempo de espera', () {
      final failure = mapNutritionError(TimeoutException('lento'));
      expect(failure.message, contains('tardó demasiado'));
    });

    test('FormatException → respuesta no válida', () {
      final failure = mapNutritionError(const FormatException('bad json'));
      expect(failure.message, contains('no es válida'));
    });

    test('PostgrestException → mensaje de guardado con el detalle', () {
      final failure = mapNutritionError(
        const PostgrestException(message: 'violates RLS'),
      );
      expect(failure.message, contains('No se pudo guardar'));
      expect(failure.message, contains('violates RLS'));
    });

    test('error desconocido → mensaje genérico, nunca silencioso', () {
      final failure = mapNutritionError(Exception('algo raro'));
      expect(failure.message, isNotEmpty);
      expect(failure.message, contains('inesperado'));
    });
  });
}
