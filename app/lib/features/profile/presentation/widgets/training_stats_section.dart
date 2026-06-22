import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../state/training_stats_providers.dart';
import 'stat_card.dart';

/// Bloque de stats agregadas de entreno (acento teal) en el Perfil: tres
/// métricas reales —"Entrenos" (total), "Este mes" y "Racha" (semanas
/// consecutivas con ≥3 entrenos)—. Cada métrica observa su propio provider, así
/// que degradan de forma independiente sin tumbar la pantalla.
class TrainingStatsSection extends ConsumerWidget {
  const TrainingStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalWorkoutsProvider);
    final thisMonth = ref.watch(workoutsThisMonthProvider);
    final streak = ref.watch(weeklyStreakProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: StatCard(label: 'Entrenos', value: total)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: StatCard(label: 'Este mes', value: thisMonth)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: StatCard(label: 'Racha', value: streak)),
      ],
    );
  }
}
