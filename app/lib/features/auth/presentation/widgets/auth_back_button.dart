import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Flecha atrás (chevron) de las pantallas de auth.
///
/// Solo se muestra si hay algo a lo que volver ([Navigator.canPop]); en la
/// pantalla raíz (login dentro del `AuthGate`) no hay pila, así que queda oculta.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left),
        color: context.palette.textSecondary,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tooltip: 'Atrás',
      ),
    );
  }
}
