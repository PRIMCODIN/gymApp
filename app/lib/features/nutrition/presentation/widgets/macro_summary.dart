import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/daily_totals.dart';

/// Desglose de macros del día: proteína, carbos y grasa en gramos.
///
/// Tres columnas legibles (número protagonista + etiqueta tenue). Todo del
/// theme/tokens; sin hex ni tamaños sueltos.
class MacroSummary extends StatelessWidget {
  const MacroSummary({super.key, required this.totals});

  final DailyTotals totals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroItem(label: 'Proteína', grams: totals.proteina)),
        Expanded(child: _MacroItem(label: 'Carbos', grams: totals.carbos)),
        Expanded(child: _MacroItem(label: 'Grasa', grams: totals.grasa)),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({required this.label, required this.grams});

  final String label;
  final double grams;

  /// Formatea gramos sin decimales superfluos (40.0 → "40", 40.5 → "40.5").
  String get _value =>
      grams == grams.roundToDouble() ? grams.round().toString() : '$grams';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text('$_value g', style: textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(label.toUpperCase(), style: textTheme.labelSmall),
      ],
    );
  }
}
