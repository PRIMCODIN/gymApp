import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/calorie_goal_supabase_datasource.dart';
import '../../data/repositories/calorie_goal_repository_impl.dart';
import '../../domain/entities/food_log.dart';
import '../../domain/repositories/calorie_goal_repository.dart';
import '../../domain/usecases/fetch_today_food_logs.dart';
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

// --- Comidas de hoy (food_logs filtrado por fecha = hoy) ---

final fetchTodayFoodLogsProvider = Provider<FetchTodayFoodLogs>(
  // Reutiliza el repositorio de food_logs ya definido en meal_entry_controller,
  // ahora extendido con la lectura.
  (ref) => FetchTodayFoodLogs(ref.watch(foodLogRepositoryProvider)),
);

/// Comidas registradas hoy, más reciente primero. La pantalla principal lo
/// observa; tras guardar una comida se invalida para que la UI se recomponga.
final todayFoodLogsProvider = FutureProvider<List<FoodLog>>((ref) {
  return ref.watch(fetchTodayFoodLogsProvider).call();
});

/// Objetivo de kcal diario del usuario (default 2000). No depende de las comidas,
/// así que no se invalida al guardar.
final dailyCalorieGoalProvider = FutureProvider<int>((ref) {
  return ref.watch(getDailyCalorieGoalProvider).call();
});
