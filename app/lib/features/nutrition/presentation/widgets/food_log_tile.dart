import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/food_log.dart';

/// Tarjeta de una comida de la lista del día: descripción + kcal + macros.
class FoodLogTile extends StatelessWidget {
  const FoodLogTile({super.key, required this.log});

  final FoodLog log;

  /// Formatea un número sin decimales superfluos (40.0 → "40", 40.5 → "40.5").
  String _fmt(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final n = log.nutrition;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(log.descripcion, style: textTheme.bodyMedium),
              ),
              const SizedBox(width: AppSpacing.m),
              Text(
                '${n.kcal.round()} kcal',
                style: textTheme.labelLarge?.copyWith(
                  color: palette.accentNutrition,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'P ${_fmt(n.proteina)} g · C ${_fmt(n.carbos)} g · G ${_fmt(n.grasa)} g',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
