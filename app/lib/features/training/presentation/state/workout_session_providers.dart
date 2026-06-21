import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/workout_supabase_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/previous_set_performance.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/cancel_workout.dart';
import '../../domain/usecases/fetch_previous_performance.dart';
import '../../domain/usecases/finish_workout.dart';
import '../../domain/usecases/start_workout.dart';

/// Cableado de dependencias de la sesión de entreno (data → domain), expuesto a
/// presentation vía Riverpod. Mismo patrón que `exercise_catalog_providers.dart`
/// y `meal_entry_controller.dart`.

final workoutSupabaseDataSourceProvider =
    Provider<WorkoutSupabaseDataSource>((ref) {
  return WorkoutSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.watch(workoutSupabaseDataSourceProvider));
});

final startWorkoutProvider = Provider<StartWorkout>(
  (ref) => StartWorkout(ref.watch(workoutRepositoryProvider)),
);

final fetchPreviousPerformanceProvider = Provider<FetchPreviousPerformance>(
  (ref) => FetchPreviousPerformance(ref.watch(workoutRepositoryProvider)),
);

final finishWorkoutProvider = Provider<FinishWorkout>(
  (ref) => FinishWorkout(ref.watch(workoutRepositoryProvider)),
);

final cancelWorkoutProvider = Provider<CancelWorkout>(
  (ref) => CancelWorkout(ref.watch(workoutRepositoryProvider)),
);

/// Rendimiento anterior (columna PREVIOUS) de un ejercicio, cargado por
/// `exerciseId`. `FutureProvider.family` entrega un `AsyncValue` que la fila de
/// set usa para mostrar loading / error / dato (o "—" si la lista viene vacía).
final previousPerformanceProvider =
    FutureProvider.family<List<PreviousSetPerformance>, int>((ref, exerciseId) {
  return ref.watch(fetchPreviousPerformanceProvider).call(exerciseId);
});
