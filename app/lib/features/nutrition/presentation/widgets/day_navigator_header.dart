import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/daily_nutrition_providers.dart';
import '../utils/day_label.dart';

/// Cabecera de navegación entre días: ◀ / etiqueta de fecha / ▶.
///
/// Mueve el [selectedDayProvider] un día atrás o adelante; al cambiarlo, las
/// comidas del día se recomponen solas. No permite navegar al futuro: ▶ se
/// deshabilita cuando el día seleccionado es hoy.
class DayNavigatorHeader extends ConsumerWidget {
  const DayNavigatorHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final selectedDay = ref.watch(selectedDayProvider);
    final today = DateUtils.dateOnly(DateTime.now());
    final isToday = !selectedDay.isBefore(today);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () =>
              ref.read(selectedDayProvider.notifier).previousDay(),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Día anterior',
        ),
        Expanded(
          child: Text(
            formatDayLabel(selectedDay, today),
            textAlign: TextAlign.center,
            style: textTheme.labelLarge,
          ),
        ),
        IconButton(
          // Deshabilitado en hoy: no se navega al futuro.
          onPressed: isToday
              ? null
              : () => ref.read(selectedDayProvider.notifier).nextDay(),
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Día siguiente',
        ),
      ],
    );
  }
}
