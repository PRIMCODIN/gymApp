import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

/// Raíz de la app. Aplica el theme central del design system.
///
/// Dark-only por ahora: forzamos `ThemeMode.dark`. Cuando exista un modo claro,
/// basta con definir `theme` (light) aquí; las pantallas no cambian porque
/// consumen tokens semánticos, no hex sueltos.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Assistant',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
