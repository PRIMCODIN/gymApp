import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/nutrition_failure.dart';
import '../../domain/entities/food_log_entry.dart';
import '../state/daily_nutrition_providers.dart';
import '../state/meal_entry_controller.dart';
import 'add_meal_sheet.dart';

/// Tarjeta de una comida de la lista del día: descripción + kcal + macros, con
/// acciones para editar o borrar la comida.
class FoodLogTile extends ConsumerWidget {
  const FoodLogTile({super.key, required this.entry});

  final FoodLogEntry entry;

  /// Formatea un número sin decimales superfluos (40.0 → "40", 40.5 → "40.5").
  String _fmt(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';

  /// Abre el formulario en modo edición, precargado con los valores actuales.
  void _onEdit(BuildContext context, WidgetRef ref) {
    showAddMealSheet(context, ref, existing: entry);
  }

  /// Pide confirmación antes de borrar (nunca borrado silencioso). Al confirmar,
  /// borra y refresca la lista del día reactivamente; ante error, muestra aviso.
  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar comida'),
        content: Text('¿Seguro que quieres borrar "${entry.descripcion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(deleteFoodLogProvider).call(entry.id);
      // Reactividad: invalidar la lectura del día recompone barra + macros + lista.
      ref.invalidate(foodLogsForDayProvider);
    } catch (error) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(mapNutritionError(error).message)),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final n = entry.nutrition;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(entry.descripcion, style: textTheme.bodyMedium),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'P ${_fmt(n.proteina)} g · C ${_fmt(n.carbos)} g · G ${_fmt(n.grasa)} g',
                  style: textTheme.bodySmall,
                ),
              ),
              _TileAction(
                icon: Icons.edit_outlined,
                tooltip: 'Editar',
                color: palette.textSecondary,
                onPressed: () => _onEdit(context, ref),
              ),
              _TileAction(
                icon: Icons.delete_outline,
                tooltip: 'Borrar',
                color: palette.textSecondary,
                onPressed: () => _onDelete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Icono de acción compacto para la tarjeta de comida (editar / borrar).
class _TileAction extends StatelessWidget {
  const _TileAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      iconSize: AppSpacing.l,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.only(left: AppSpacing.s),
      constraints: const BoxConstraints(),
    );
  }
}
