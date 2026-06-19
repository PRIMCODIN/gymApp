import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/daily_totals.dart';
import '../../domain/entities/food_log.dart';
import '../state/daily_nutrition_providers.dart';
import '../widgets/add_meal_sheet.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/food_log_tile.dart';

/// Pantalla de Nutrición: tracking del consumo de HOY.
///
/// Muestra la barra de calorías (total / objetivo), el desglose de macros y la
/// lista de comidas del día (lectura directa a Supabase, reactiva). El botón "+"
/// abre el formulario de añadir comida en un bottom sheet. Al guardar, la vista
/// se recompone sola al invalidarse [todayFoodLogsProvider].
class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayFoodLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrición')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.palette.accentNutrition,
        onPressed: () => showAddMealSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorState(
            onRetry: () => ref.invalidate(todayFoodLogsProvider),
          ),
          data: (logs) => _DayContent(logs: logs),
        ),
      ),
    );
  }
}

/// Contenido del día: resumen + lista (o estado vacío). El resumen siempre se
/// muestra (a cero si no hay comidas) para que la barra y los macros estén
/// presentes desde el primer momento.
class _DayContent extends StatelessWidget {
  const _DayContent({required this.logs});

  final List<FoodLog> logs;

  @override
  Widget build(BuildContext context) {
    final totals = DailyTotals.fromLogs(logs);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        CalorieSummaryCard(totals: totals),
        const SizedBox(height: AppSpacing.l),
        if (logs.isEmpty)
          const _EmptyState()
        else
          // Más reciente primero (orden garantizado por la consulta). Se separa
          // cada tarjeta con un hueco uniforme.
          for (final log in logs) ...[
            FoodLogTile(log: log),
            const SizedBox(height: AppSpacing.m),
          ],
      ],
    );
  }
}

/// Estado vacío: aún no hay comidas registradas hoy.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: context.palette.textSecondary,
            size: AppSpacing.xl,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Aún no has registrado comidas hoy.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pulsa el botón + para añadir la primera.',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Estado de error de la lectura, con opción de reintentar.
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
              'No se pudieron cargar tus comidas de hoy.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
