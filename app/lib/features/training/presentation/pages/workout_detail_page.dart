import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../nutrition/presentation/utils/day_label.dart';
import '../../data/training_failure.dart';
import '../../data/workout_stats.dart';
import '../../domain/entities/workout_detail.dart';
import '../state/workout_history_providers.dart';
import '../utils/workout_history_format.dart';
import '../utils/workout_session_format.dart';
import '../widgets/workout_detail_exercise_card.dart';

/// Detalle de un workout finalizado en SOLO LECTURA (D1): cabecera (nombre, fecha,
/// duración, resumen) y la lista de ejercicios con sus sets. Permite borrar el
/// workout entero. La edición fina (nombre/fecha/sets) llegará en D2; la estructura
/// ya la soporta. Carga con `workoutDetailProvider` (AsyncValue).
class WorkoutDetailPage extends ConsumerWidget {
  const WorkoutDetailPage({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del entreno')),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorState(
            onRetry: () => ref.invalidate(workoutDetailProvider(workoutId)),
          ),
          data: (detail) => _DetailView(detail: detail),
        ),
      ),
    );
  }
}

/// Cuerpo del detalle: cabecera + ejercicios (scroll) + botón de borrar fijo.
class _DetailView extends ConsumerWidget {
  const _DetailView({required this.detail});

  final WorkoutDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _DetailHeader(detail: detail),
              const SizedBox(height: AppSpacing.l),
              for (final exercise in detail.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: WorkoutDetailExerciseCard(exercise: exercise),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: AppButton(
            label: 'Borrar workout',
            variant: AppButtonVariant.neutral,
            onPressed: () => _delete(context, ref),
          ),
        ),
      ],
    );
  }

  /// Confirma y borra el workout; refresca el día y el mes y cierra el detalle.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar entreno'),
        content: Text('¿Seguro que quieres borrar "${detail.nombre}"?'),
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
      await ref.read(deleteWorkoutProvider).call(detail.id);
      // Refresca el calendario (marcadores) y la lista del día.
      ref.invalidate(workoutDatesForMonthProvider);
      ref.invalidate(workoutsForDayProvider);
      navigator.pop();
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Entreno borrado.')));
    } catch (error) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(mapTrainingError(error).message)));
    }
  }
}

/// Cabecera del detalle: nombre + fecha/duración + resumen.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail});

  final WorkoutDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    final fecha = formatDayLabel(detail.fecha, DateTime.now());
    final duracion = detail.duracionS;
    final subtitle = duracion == null
        ? fecha
        : '$fecha · ${formatStopwatch(Duration(seconds: duracion))}';
    final volumen = computeTotalVolume(
      detail.exercises.expand((exercise) => exercise.sets),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(detail.nombre, style: textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          formatSummaryLine(detail.numEjercicios, detail.numSets, volumen),
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// Estado de error de la carga del detalle, con reintento.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo cargar el entreno.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
