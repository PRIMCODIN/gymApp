import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../profile/domain/entities/last_workout.dart';
import '../../../profile/presentation/state/training_stats_providers.dart';
import '../../../training/presentation/pages/workout_history_page.dart';
import '../utils/relative_date.dart';
import 'card_block_states.dart';

/// Tarjeta Entreno de Inicio (acento teal, ver `specs/006_inicio.md` §6).
///
/// Lectura agregada read-only: último entreno finalizado (nombre + fecha relativa)
/// y racha semanal. Tocar la tarjeta lleva al Historial de Entreno (regla de la
/// spec: tarjeta = ver en profundidad; el botón de empezar/continuar vive aparte).
///
/// Cada métrica observa su propio provider y se resuelve por separado, así que si
/// una lectura falla su bloque degrada con reintento sin tumbar la otra ni Inicio
/// (spec §8: estados por tarjeta, no spinner global).
class TrainingCard extends ConsumerWidget {
  const TrainingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final lastWorkout = ref.watch(lastFinishedWorkoutProvider);
    final streak = ref.watch(weeklyStreakProvider);

    return GestureDetector(
      onTap: () => _openHistory(context),
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('ENTRENO', style: textTheme.labelSmall),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: palette.accentTraining,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _LastWorkoutBlock(
              value: lastWorkout,
              onRetry: () => ref.invalidate(lastFinishedWorkoutProvider),
            ),
            const SizedBox(height: AppSpacing.m),
            _StreakBlock(
              value: streak,
              onRetry: () => ref.invalidate(weeklyStreakProvider),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkoutHistoryPage()),
    );
  }
}

/// Bloque "último entreno": etiqueta + nombre + fecha relativa. Cubre los tres
/// estados del provider con altura reservada para que el layout no salte.
class _LastWorkoutBlock extends StatelessWidget {
  const _LastWorkoutBlock({required this.value, required this.onRetry});

  final AsyncValue<LastWorkout?> value;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ÚLTIMO ENTRENO', style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        value.when(
          loading: () => const BlockPlaceholder(),
          error: (_, _) => BlockError(onRetry: onRetry),
          data: (workout) {
            // Vacío: sin entrenos finalizados todavía → texto neutro, no campos
            // en blanco (spec §6).
            if (workout == null) {
              return Text(
                'Aún no has registrado entrenos',
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.nombre,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  relativeDayLabel(workout.fecha),
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Bloque "racha semanal": etiqueta + número protagonista (teal) + unidad. La
/// racha 0 se presenta como "Sin racha" (no un cero protagonista), coherente con
/// el caso sin entrenos.
class _StreakBlock extends StatelessWidget {
  const _StreakBlock({required this.value, required this.onRetry});

  final AsyncValue<int> value;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RACHA SEMANAL', style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        value.when(
          loading: () => const BlockPlaceholder(),
          error: (_, _) => BlockError(onRetry: onRetry),
          data: (weeks) {
            if (weeks <= 0) {
              return Text(
                'Sin racha',
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$weeks',
                  style: textTheme.headlineMedium?.copyWith(
                    color: palette.accentTraining,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  weeks == 1 ? 'semana' : 'semanas',
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
