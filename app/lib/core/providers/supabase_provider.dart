import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Expone el cliente de Supabase a través de Riverpod en vez de usar el singleton
/// global directamente en los widgets/datasources (ver `specs/conventions.md`).
///
/// Supabase debe estar inicializado (`Supabase.initialize`) antes de leer este
/// provider; se hace en `main()`.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
