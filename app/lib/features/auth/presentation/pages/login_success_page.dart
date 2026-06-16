import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/auth_user.dart';
import '../state/auth_providers.dart';

/// Pantalla accesible solo con sesión activa. Muestra el usuario logueado y
/// permite cerrar sesión. Estilada con el design system.
class LoginSuccessPage extends ConsumerWidget {
  const LoginSuccessPage({super.key, required this.user});

  final AuthUser user;

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(signOutProvider).call();
      // No navegamos manualmente: el AuthGate vuelve a Login al cambiar el stream.
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login Successful')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SESIÓN ACTIVA', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    user.email ?? '(sin email)',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('USER ID', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(user.id, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Cerrar sesión',
                    variant: AppButtonVariant.neutral,
                    onPressed: () => _signOut(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
