import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

/// Separador "O continúa con" de las pantallas de auth: dos líneas sutiles de
/// `divider` con un texto tenue centrado.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'O continúa con'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final line = Expanded(
      child: Container(height: 0.5, color: palette.divider),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.textTertiary,
                ),
          ),
        ),
        line,
      ],
    );
  }
}
