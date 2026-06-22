import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// Tarjeta de una métrica de entreno (acento teal) para el bloque de stats del
/// Perfil. Recibe el estado ya resuelto ([value]) y cubre loading/error/data:
/// si la lectura falla degrada a "—" (no rompe la pantalla). La altura del hueco
/// del número es fija para que no salte el layout entre estados.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});

  /// Etiqueta en español (p.ej. "Entrenos", "Este mes").
  final String label;

  /// Estado de la métrica: loading / error (degradado) / data (el recuento).
  final AsyncValue<int> value;

  /// Altura reservada para el número, común a los tres estados (y al hueco
  /// reservado de la racha, ver `TrainingStatsSection`).
  static const double valueSlotHeight = 40;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final numberStyle = textTheme.headlineMedium?.copyWith(
      color: palette.accentTraining,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: valueSlotHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: value.when(
                  loading: () => SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.accentTraining,
                    ),
                  ),
                  // Estado degradado: la métrica no rompe la tarjeta.
                  error: (_, _) => Text(
                    '—',
                    style: numberStyle?.copyWith(color: palette.textSecondary),
                  ),
                  data: (count) => Text('$count', style: numberStyle),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label.toUpperCase(), style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
