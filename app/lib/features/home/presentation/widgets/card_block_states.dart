import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

/// Estados locales compartidos por las tarjetas de Inicio (Entreno y Nutrición).
///
/// Cada métrica de una tarjeta resuelve su propio async y degrada sola (spec
/// §8: estados por tarjeta, no spinner global). Para que ambas tarjetas se
/// sientan hermanas y no se dupliquen widgets mudos, el placeholder de carga y
/// el estado de error con reintento viven aquí y los consumen las dos.

/// Placeholder de carga local de un bloque: una barra atenuada de altura fija
/// para que el bloque ocupe sitio mientras resuelve y el layout no salte.
class BlockPlaceholder extends StatelessWidget {
  const BlockPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 16,
      width: 120,
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
    );
  }
}

/// Estado degradado local de un bloque: aviso breve + reintento. No tumba la
/// tarjeta ni los demás bloques (spec §8). El tap de "Reintentar" lo consume el
/// botón, así que no se propaga al `GestureDetector` de la tarjeta.
class BlockError extends StatelessWidget {
  const BlockError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'No se pudo cargar',
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
