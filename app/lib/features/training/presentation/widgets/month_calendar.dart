import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../utils/calendar_month.dart';

/// Rejilla del calendario mensual del historial, construida con widgets propios y
/// las funciones puras de `calendar_month.dart` (sin dependencia de calendario).
///
/// Marca con un punto teal los días presentes en [markedDays]; resalta el día
/// [selectedDay]; avisa de la selección con [onSelectDay]. Las celdas son
/// cuadradas (AspectRatio) para no usar tamaños sueltos.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.markedDays,
    required this.onSelectDay,
  });

  final int year;
  final int month;
  final DateTime selectedDay;
  final Set<DateTime> markedDays;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final days = daysInMonth(year, month);
    // Huecos antes del día 1 (lunes = 0 huecos ... domingo = 6 huecos).
    final leading = firstWeekdayOfMonth(year, month) - 1;

    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const Expanded(child: SizedBox.shrink()),
      for (var day = 1; day <= days; day++)
        Expanded(
          child: _DayCell(
            date: DateTime(year, month, day),
            selected: isSameDay(DateTime(year, month, day), selectedDay),
            marked: markedDays.any(
              (d) => isSameDay(d, DateTime(year, month, day)),
            ),
            onTap: onSelectDay,
          ),
        ),
    ];
    // Completa la última fila para que las celdas mantengan el ancho.
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: SizedBox.shrink()));
    }

    final weeks = <Widget>[
      for (var i = 0; i < cells.length; i += 7)
        Row(children: cells.sublist(i, i + 7)),
    ];

    return Column(
      children: [
        const _WeekdayHeader(),
        const SizedBox(height: AppSpacing.xs),
        ...weeks,
      ],
    );
  }
}

/// Día concreto: número + punto marcador, resaltado si está seleccionado.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.marked,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool marked;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Material(
          color: selected ? palette.accentTraining : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.input),
            onTap: () => onTap(date),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? AppColors.background
                        : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Punto marcador: teal en días con entreno; en el día seleccionado
                // el fondo ya es teal, así que el punto va oscuro para contrastar.
                SizedBox(
                  height: AppSpacing.s,
                  width: AppSpacing.s,
                  child: marked
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppColors.background
                                : palette.accentTraining,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera con las iniciales de los días de la semana (L M X J V S D).
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Row(
      children: [
        for (final initial in kWeekdayInitials)
          Expanded(
            child: Center(
              child: Text(
                initial,
                style: textTheme.labelSmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
