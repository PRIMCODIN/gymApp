import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/daily_totals.dart';
import '../../domain/entities/food_log_entry.dart';
import '../state/daily_nutrition_providers.dart';
import '../widgets/add_meal_sheet.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/day_navigator_header.dart';
import '../widgets/food_log_tile.dart';

/// Pantalla de Nutrición: tracking del consumo del día seleccionado.
///
/// Muestra la cabecera de navegación entre días, la barra de calorías (total /
/// objetivo), el desglose de macros y la lista de comidas del día (lectura
/// directa a Supabase, reactiva). El botón "+" abre el formulario de añadir
/// comida en un bottom sheet. Al guardar/editar/borrar, la vista se recompone
/// sola al invalidarse [foodLogsForDayProvider].
class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(foodLogsForDayProvider);

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
            onRetry: () => ref.invalidate(foodLogsForDayProvider),
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

  final List<FoodLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    final totals = DailyTotals.fromLogs(logs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera de día + resumen fijos: anclados arriba, NO scrollean.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DayNavigatorHeader(),
              const SizedBox(height: AppSpacing.s),
              CalorieSummaryCard(totals: totals),
            ],
          ),
        ),
        // Solo la lista de comidas hace scroll (lazy).
        Expanded(
          child: logs.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  itemCount: logs.length,
                  // Más reciente primero (orden garantizado por la consulta).
                  // Cada tarjeta se separa con un hueco uniforme.
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: FoodLogTile(entry: logs[index]),
                  ),
                ),
        ),
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
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: context.palette.textSecondary,
            size: AppSpacing.xl,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'No hay comidas registradas este día.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pulsa el botón + para añadir una.',
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
