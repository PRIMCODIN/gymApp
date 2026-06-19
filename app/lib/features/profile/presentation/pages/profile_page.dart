import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/state/auth_providers.dart';

/// Pantalla de Perfil. Esqueleto vacío por ahora: solo el botón "Cerrar sesión".
/// El resto del perfil (datos, objetivos, etc.) llega en fases futuras.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              const Spacer(),
              AppButton(
                label: 'Cerrar sesión',
                variant: AppButtonVariant.neutral,
                onPressed: () => _signOut(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
