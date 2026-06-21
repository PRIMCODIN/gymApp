import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/workout_history_supabase_datasource.dart';
import '../../data/repositories/workout_history_repository_impl.dart';
import '../../domain/entities/workout_detail.dart';
import '../../domain/entities/workout_summary.dart';
import '../../domain/repositories/workout_history_repository.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/fetch_workout_dates_for_month.dart';
import '../../domain/usecases/fetch_workout_detail.dart';
import '../../domain/usecases/fetch_workouts_for_day.dart';
import '../../domain/usecases/save_workout_edits.dart';

/// Cableado de dependencias del historial (data → domain), expuesto a presentation
/// vía Riverpod. Mismo patrón que `routine_providers.dart`: lectura directa a
/// Supabase (sin n8n), expuesta como `FutureProvider` que entrega un `AsyncValue`
/// (cubre loading/error/data por diseño).

final workoutHistorySupabaseDataSourceProvider =
    Provider<WorkoutHistorySupabaseDataSource>((ref) {
  return WorkoutHistorySupabaseDataSource(ref.watch(supabaseClientProvider));
});

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((
  ref,
) {
  return WorkoutHistoryRepositoryImpl(
    ref.watch(workoutHistorySupabaseDataSourceProvider),
  );
});

final fetchWorkoutDatesForMonthProvider = Provider<FetchWorkoutDatesForMonth>(
  (ref) => FetchWorkoutDatesForMonth(ref.watch(workoutHistoryRepositoryProvider)),
);

final fetchWorkoutsForDayProvider = Provider<FetchWorkoutsForDay>(
  (ref) => FetchWorkoutsForDay(ref.watch(workoutHistoryRepositoryProvider)),
);

final fetchWorkoutDetailProvider = Provider<FetchWorkoutDetail>(
  (ref) => FetchWorkoutDetail(ref.watch(workoutHistoryRepositoryProvider)),
);

final deleteWorkoutProvider = Provider<DeleteWorkout>(
  (ref) => DeleteWorkout(ref.watch(workoutHistoryRepositoryProvider)),
);

final saveWorkoutEditsProvider = Provider<SaveWorkoutEdits>(
  (ref) => SaveWorkoutEdits(ref.watch(workoutHistoryRepositoryProvider)),
);

/// Clave del mes mostrado para el provider de marcadores del calendario.
typedef MonthKey = ({int year, int month});

/// Días con workout finalizado del mes mostrado (marcadores del calendario).
final workoutDatesForMonthProvider =
    FutureProvider.family<Set<DateTime>, MonthKey>((ref, key) {
  return ref
      .watch(fetchWorkoutDatesForMonthProvider)
      .call(key.year, key.month);
});

/// Workouts (resumen) del día seleccionado.
final workoutsForDayProvider =
    FutureProvider.family<List<WorkoutSummary>, DateTime>((ref, day) {
  return ref.watch(fetchWorkoutsForDayProvider).call(day);
});

/// Detalle de un workout, cargado por `workoutId`.
final workoutDetailProvider =
    FutureProvider.family<WorkoutDetail, int>((ref, workoutId) {
  return ref.watch(fetchWorkoutDetailProvider).call(workoutId);
});
