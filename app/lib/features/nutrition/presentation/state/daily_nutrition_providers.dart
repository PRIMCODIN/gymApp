import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/calorie_goal_supabase_datasource.dart';
import '../../data/repositories/calorie_goal_repository_impl.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/repositories/calorie_goal_repository.dart';
import '../../domain/usecases/fetch_food_logs_by_date.dart';
import '../../domain/usecases/get_daily_calorie_goal.dart';
import 'meal_entry_controller.dart';

/// Providers de LECTURA de la pantalla del día (consumo de hoy + objetivo).
///
/// La lectura es directa a Supabase (no pasa por n8n). Se exponen como
/// `FutureProvider`, que entrega un `AsyncValue` y cubre por diseño los estados
/// loading/error/data que la UI debe manejar.

// --- Objetivo de calorías (profiles.objetivo_kcal_diario) ---

final calorieGoalSupabaseDataSourceProvider =
    Provider<CalorieGoalSupabaseDataSource>((ref) {
  return CalorieGoalSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final calorieGoalRepositoryProvider = Provider<CalorieGoalRepository>((ref) {
  return CalorieGoalRepositoryImpl(
    ref.watch(calorieGoalSupabaseDataSourceProvider),
  );
});

final getDailyCalorieGoalProvider = Provider<GetDailyCalorieGoal>(
  (ref) => GetDailyCalorieGoal(ref.watch(calorieGoalRepositoryProvider)),
);

// --- Comidas del día seleccionado (food_logs filtrado por fecha) ---

final fetchFoodLogsByDateProvider = Provider<FetchFoodLogsByDate>(
  // Reutiliza el repositorio de food_logs ya definido en meal_entry_controller,
  // ahora extendido con la lectura por fecha.
  (ref) => FetchFoodLogsByDate(ref.watch(foodLogRepositoryProvider)),
);

/// Día actualmente visible en la pantalla de nutrición. Init = hoy (normalizado
/// a medianoche local). La cabecera de día lo cambia con ◀ / ▶; al moverlo, las
/// comidas del día se recomponen solas. El estado se mantiene siempre a
/// medianoche local (el constructor de [DateTime] normaliza el desbordamiento de
/// día/mes y es estable frente a cambios de horario).
class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateUtils.dateOnly(DateTime.now());

  void previousDay() => state = DateTime(state.year, state.month, state.day - 1);

  void nextDay() => state = DateTime(state.year, state.month, state.day + 1);
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

/// Comidas del día seleccionado, más reciente primero. La pantalla principal lo
/// observa; tras guardar/editar/borrar una comida se invalida para que la UI se
/// recomponga.
final foodLogsForDayProvider = FutureProvider<List<FoodLogEntry>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(fetchFoodLogsByDateProvider).call(day);
});

/// Objetivo de kcal diario del usuario (default 2000). No depende de las comidas,
/// así que no se invalida al guardar.
final dailyCalorieGoalProvider = FutureProvider<int>((ref) {
  return ref.watch(getDailyCalorieGoalProvider).call();
});
