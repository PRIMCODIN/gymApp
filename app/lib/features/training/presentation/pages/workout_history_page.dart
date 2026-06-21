import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../nutrition/presentation/utils/day_label.dart';
import '../../domain/entities/workout_summary.dart';
import '../state/history_calendar_controller.dart';
import '../state/workout_history_providers.dart';
import '../utils/calendar_month.dart';
import '../widgets/month_calendar.dart';
import '../widgets/workout_summary_card.dart';
import 'workout_detail_page.dart';

/// Historial de entrenos: calendario mensual con marcadores en los días con
/// entreno y, debajo, la lista de workouts del día seleccionado. Por defecto
/// muestra el mes actual con hoy seleccionado. Solo lectura (abrir un workout lleva
/// a su detalle). Estado del calendario en `historyCalendarControllerProvider`;
/// las cargas, en `FutureProvider` (AsyncValue: loading/error/data).
class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(historyCalendarControllerProvider);
    final controller = ref.read(historyCalendarControllerProvider.notifier);
    final monthKey = (year: calendar.year, month: calendar.month);
    final datesAsync = ref.watch(workoutDatesForMonthProvider(monthKey));
    final dayAsync = ref.watch(workoutsForDayProvider(calendar.selectedDay));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            _CalendarHeader(
              label: monthYearLabel(calendar.year, calendar.month),
              onPrev: controller.prevMonth,
              onNext: controller.nextMonth,
            ),
            const SizedBox(height: AppSpacing.m),
            datesAsync.when(
              loading: () => const _CalendarPlaceholder(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => _CalendarPlaceholder(
                child: TextButton(
                  onPressed: () =>
                      ref.invalidate(workoutDatesForMonthProvider(monthKey)),
                  child: const Text('Reintentar'),
                ),
              ),
              data: (dates) => MonthCalendar(
                year: calendar.year,
                month: calendar.month,
                selectedDay: calendar.selectedDay,
                markedDays: dates,
                onSelectDay: controller.selectDay,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              formatDayLabel(calendar.selectedDay, DateTime.now()),
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            dayAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.l),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => _DayError(
                onRetry: () =>
                    ref.invalidate(workoutsForDayProvider(calendar.selectedDay)),
              ),
              data: (workouts) => workouts.isEmpty
                  ? const _DayEmpty()
                  : _DayWorkouts(
                      workouts: workouts,
                      onOpen: (id) => _openDetail(context, id),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, int workoutId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailPage(workoutId: workoutId),
      ),
    );
  }
}

/// Cabecera del calendario: ◀ mes año ▶.
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          tooltip: 'Mes anterior',
          icon: Icon(Icons.chevron_left, color: palette.textSecondary),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: 'Mes siguiente',
          icon: Icon(Icons.chevron_right, color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// Contenedor de tamaño estable para los estados de carga/error del calendario, de
/// forma que la cabecera no salte mientras carga.
class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Center(child: child),
    );
  }
}

/// Lista de workouts del día seleccionado.
class _DayWorkouts extends StatelessWidget {
  const _DayWorkouts({required this.workouts, required this.onOpen});

  final List<WorkoutSummary> workouts;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final workout in workouts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: WorkoutSummaryCard(
              summary: workout,
              onTap: () => onOpen(workout.id),
            ),
          ),
      ],
    );
  }
}

/// Estado vacío: el día seleccionado no tiene entrenos.
class _DayEmpty extends StatelessWidget {
  const _DayEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      child: Text(
        'No hay entrenos este día.',
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      ),
    );
  }
}

/// Estado de error de la carga del día, con reintento.
class _DayError extends StatelessWidget {
  const _DayError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      child: Column(
        children: [
          Text(
            'No se pudieron cargar los entrenos.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
