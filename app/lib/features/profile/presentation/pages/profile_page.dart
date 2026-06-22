import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/state/auth_providers.dart';
import '../../domain/entities/profile.dart';
import '../state/profile_providers.dart';
import '../widgets/calorie_goal_card.dart';
import '../widgets/edit_goal_dialog.dart';
import '../widgets/edit_personal_data_form.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/profile_header.dart';

/// Pantalla de Perfil: identidad mínima, objetivo de kcal editable, datos
/// antropométricos (informativos y editables a mano en free) y cierre de sesión.
///
/// Lee el perfil directo de Supabase vía [profileProvider] (cubre
/// loading/error/data); el email sale de la sesión de Auth, no de `profiles`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    // Email desde la sesión de Auth (no de `profiles`).
    final email = ref.watch(authStateProvider).asData?.value?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorState(
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (profile) => _ProfileContent(profile: profile, email: email),
        ),
      ),
    );
  }
}

/// Contenido del perfil cargado: cabecera, objetivo, datos y acciones.
class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile, required this.email});

  final Profile profile;
  final String? email;

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            name: profile.name,
            email: email,
            plan: profile.plan,
          ),
          const SizedBox(height: AppSpacing.l),
          CalorieGoalCard(
            kcalGoal: profile.kcalGoal,
            onEdit: () =>
                showEditGoalDialog(context, current: profile.kcalGoal),
          ),
          const SizedBox(height: AppSpacing.l),
          PersonalDataSection(profile: profile),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            label: 'Editar mis datos',
            variant: AppButtonVariant.neutral,
            onPressed: () => showEditPersonalDataForm(context, profile: profile),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Cerrar sesión',
            variant: AppButtonVariant.destructive,
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Estado de error de la lectura del perfil, con opción de reintentar.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo cargar tu perfil.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
