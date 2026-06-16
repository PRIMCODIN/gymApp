import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sin claves no se puede inicializar Supabase: mostramos un error claro en vez
  // de fallar de forma opaca más adelante (ver `specs/conventions.md`).
  if (!Env.isValid) {
    runApp(const _ConfigErrorApp(message: Env.missingKeysMessage));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // La clave anon es la "publishable key"; `anonKey` está deprecado.
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: App()));
}

/// Pantalla de error mostrada cuando faltan las claves de Supabase.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
