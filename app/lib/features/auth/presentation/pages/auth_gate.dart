import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../state/auth_providers.dart';
import 'login_page.dart';
import 'login_success_page.dart';

/// Widget raíz que decide qué pantalla mostrar según el estado de sesión.
///
/// Observa `authStateProvider` (stream sobre `onAuthStateChange`): el cambio
/// entre Login y "Login Successful" es 100% reactivo, sin navegación manual.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) =>
          user == null ? const LoginPage() : LoginSuccessPage(user: user),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              'Error al cargar la sesión:\n$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
