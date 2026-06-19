import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

/// Fila de botones de login social (Apple / Google).
///
/// Están **deshabilitados a propósito**: aún no hay OAuth configurado. Se
/// incluyen para respetar el diseño y dejar el hueco preparado; al pulsarlos solo
/// se informa de que están "próximamente". No hay lógica de login social.
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({super.key});

  void _notifySoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Inicio de sesión social: próximamente.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialTile(
          tooltip: 'Apple (próximamente)',
          onTap: () => _notifySoon(context),
          child: const Icon(Icons.apple, size: 22),
        ),
        const SizedBox(width: AppSpacing.s + AppSpacing.xs),
        _SocialTile(
          tooltip: 'Google (próximamente)',
          onTap: () => _notifySoon(context),
          child: Text(
            'G',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.palette.textTertiary,
                ),
          ),
        ),
      ],
    );
  }
}

/// Botón cuadrado de marca, con borde sutil. Atenuado para señalar que está
/// inactivo (sin OAuth todavía).
class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.child,
    required this.tooltip,
    required this.onTap,
  });

  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Opacity(
          opacity: 0.5,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: palette.divider, width: 0.5),
            ),
            child: IconTheme(
              data: IconThemeData(color: palette.textTertiary),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
