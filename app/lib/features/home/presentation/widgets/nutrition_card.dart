import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../nutrition/domain/entities/daily_totals.dart';
import '../../../nutrition/presentation/pages/nutrition_page.dart';
import '../../../nutrition/presentation/state/daily_nutrition_providers.dart';
import '../../../nutrition/presentation/widgets/macro_summary.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'card_block_states.dart';

/// Tarjeta Nutrición de Inicio (acento naranja, ver `specs/006_inicio.md` §5).
///
/// Hermana visual de [TrainingCard]: lectura agregada read-only del consumo de
/// HOY ([todayTotalsProvider], independiente del día seleccionado en Nutrición)
/// y del objetivo de kcal ([dailyCalorieGoalProvider], nullable). Tocar la
/// tarjeta lleva a la pantalla Nutrición del día de hoy; un CTA discreto del
/// caso sin objetivo lleva a Perfil para fijarlo.
///
/// Los dos providers se resuelven por separado: el bloque de calorías necesita
/// ambos (consumido y objetivo), los macros solo el consumido. Si uno falla, su
/// bloque degrada con reintento sin tumbar la tarjeta (spec §8).
class NutritionCard extends ConsumerWidget {
  const NutritionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final totals = ref.watch(todayTotalsProvider);
    final goal = ref.watch(dailyCalorieGoalProvider);

    return GestureDetector(
      onTap: () => _openTodayNutrition(context, ref),
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('NUTRICIÓN', style: textTheme.labelSmall)),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: palette.accentNutrition,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _CaloriesBlock(
              totals: totals,
              goal: goal,
              onOpenProfile: () => _openProfile(context),
              // El bloque necesita ambos providers; reintentar refresca los dos
              // (invalidar el de totales también recompone los macros: inocuo).
              onRetry: () {
                ref.invalidate(todayTotalsProvider);
                ref.invalidate(dailyCalorieGoalProvider);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            _MacrosBlock(
              totals: totals,
              onRetry: () => ref.invalidate(todayTotalsProvider),
            ),
          ],
        ),
      ),
    );
  }

  /// Resetea el día visible a HOY y luego empuja Nutrición. El reset
  /// ([SelectedDayNotifier.goToToday]) es síncrono: `state` ya vale hoy cuando
  /// la [NutritionPage] empujada hace su primer build y lee
  /// [foodLogsForDayProvider], así que aterriza en hoy sin flash del día al que
  /// el usuario hubiera navegado antes en la pestaña Nutrición.
  void _openTodayNutrition(BuildContext context, WidgetRef ref) {
    ref.read(selectedDayProvider.notifier).goToToday();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NutritionPage()),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    );
  }
}

/// Bloque de calorías: necesita consumido (totals) Y objetivo (goal).
///
/// - Cualquiera cargando → placeholder; cualquiera en error → reintento.
/// - Con objetivo → restantes (o excedido sin alarmismo) + barra + consumido/obj.
/// - Sin objetivo (`goal == null`) → solo consumido + CTA a Perfil, sin barra ni
///   restantes (no hay denominador), igual criterio que `calorie_summary_card`.
class _CaloriesBlock extends StatelessWidget {
  const _CaloriesBlock({
    required this.totals,
    required this.goal,
    required this.onOpenProfile,
    required this.onRetry,
  });

  final AsyncValue<DailyTotals> totals;
  final AsyncValue<int?> goal;
  final VoidCallback onOpenProfile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CALORÍAS DEL DÍA', style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        _content(context),
      ],
    );
  }

  Widget _content(BuildContext context) {
    // El bloque combina dos asíncronos: degrada si cualquiera no está listo.
    if (totals.isLoading || goal.isLoading) return const BlockPlaceholder();
    if (totals.hasError || goal.hasError) return BlockError(onRetry: onRetry);

    final consumed = totals.requireValue.kcal.round();
    final goalValue = goal.requireValue;

    return goalValue == null
        ? _withoutGoal(context, consumed)
        : _withGoal(context, consumed, goalValue);
  }

  /// Caso con objetivo: el número protagonista es las kcal restantes; si se
  /// supera, se muestra el exceso en acento (naranja, sin rojo de alarma).
  Widget _withGoal(BuildContext context, int consumed, int goal) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final exceeded = consumed > goal;
    final remaining = goal - consumed;
    final progress = goal <= 0 ? 0.0 : consumed / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              exceeded ? '${consumed - goal}' : '$remaining',
              style: textTheme.headlineMedium?.copyWith(
                color: exceeded ? palette.accentNutrition : null,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              exceeded ? 'kcal de más' : 'kcal restantes',
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        // La barra se llena y se queda (el clamp vive en AppProgressBar); el
        // exceso no rompe el layout.
        AppProgressBar(value: progress, context: AppProgressContext.calories),
        const SizedBox(height: AppSpacing.s),
        Text('$consumed / $goal kcal', style: textTheme.labelSmall),
      ],
    );
  }

  /// Caso sin objetivo: consumido protagonista + CTA discreto a Perfil. Sin
  /// barra ni restantes (no hay denominador). El CTA es un botón: consume el tap
  /// y no propaga al GestureDetector de la tarjeta (que lleva a Nutrición).
  Widget _withoutGoal(BuildContext context, int consumed) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$consumed', style: textTheme.headlineMedium),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'kcal de hoy',
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onOpenProfile,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: palette.accentNutritionSoft,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Fija tu objetivo de calorías en Perfil'),
          ),
        ),
      ],
    );
  }
}

/// Bloque de macros: solo depende del consumido. Reutiliza [MacroSummary] tal
/// cual; degrada solo con su propio estado.
class _MacrosBlock extends StatelessWidget {
  const _MacrosBlock({required this.totals, required this.onRetry});

  final AsyncValue<DailyTotals> totals;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MACROS', style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        totals.when(
          loading: () => const BlockPlaceholder(),
          error: (_, _) => BlockError(onRetry: onRetry),
          data: (t) => MacroSummary(totals: t),
        ),
      ],
    );
  }
}
