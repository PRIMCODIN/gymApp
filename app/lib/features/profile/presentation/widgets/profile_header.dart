import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

/// Cabecera del perfil: avatar con iniciales, nombre + email y badge de plan.
///
/// El email viene de la sesión de Auth (no de `profiles`). El badge de plan es
/// read-only (futuro punto de entrada al upgrade en pro). Las iniciales se
/// derivan del nombre; si no hay nombre, de la inicial del email.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.plan,
  });

  final String? name;
  final String? email;
  final String plan;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : 'Sin nombre';

    return Row(
      children: [
        _Avatar(initials: _initials(name, email)),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (email != null && email!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email!,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        _PlanBadge(plan: plan),
      ],
    );
  }

  /// Iniciales (1–2 letras) del nombre; si no hay, inicial del email; si tampoco,
  /// un guion.
  String _initials(String? name, String? email) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      final parts = trimmedName.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        return parts.first.characters.first.toUpperCase();
      }
      return (parts.first.characters.first + parts[1].characters.first)
          .toUpperCase();
    }
    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      return trimmedEmail.characters.first.toUpperCase();
    }
    return '–';
  }
}

/// Avatar circular con iniciales sobre `surfaceElevated`.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: textTheme.headlineMedium?.copyWith(
          color: palette.accentNutrition,
        ),
      ),
    );
  }
}

/// Badge del plan (Free/Pro): naranja sobre fondo tenue. Read-only.
class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.plan});

  final String plan;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    // 'pro' → "Pro", cualquier otro (incl. 'free') → "Free".
    final label = plan.toLowerCase() == 'pro' ? 'Pro' : 'Free';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.accentNutrition.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: palette.accentNutrition),
      ),
    );
  }
}
