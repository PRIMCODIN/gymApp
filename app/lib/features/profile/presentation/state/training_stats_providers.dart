import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/training_stats_supabase_datasource.dart';
import '../../data/repositories/training_stats_repository_impl.dart';
import '../../domain/repositories/training_stats_repository.dart';
import '../../domain/usecases/count_finished_workouts.dart';
import '../../domain/usecases/count_finished_workouts_this_month.dart';
import '../../domain/usecases/get_current_streak.dart';

/// Cableado de las stats de entreno del Perfil (data → domain), expuesto a la
/// capa de presentation vía Riverpod. Mismo patrón que `profile_providers.dart`.
///
/// Cada métrica tiene su propio `FutureProvider<int>` para que sus estados
/// loading/error/data sean independientes: si una lectura falla, su tarjeta
/// degrada sola sin afectar a la otra ni a la pantalla.

final trainingStatsDataSourceProvider =
    Provider<TrainingStatsSupabaseDataSource>((ref) {
  return TrainingStatsSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final trainingStatsRepositoryProvider = Provider<TrainingStatsRepository>((ref) {
  return TrainingStatsRepositoryImpl(
    ref.watch(trainingStatsDataSourceProvider),
  );
});

final countFinishedWorkoutsProvider = Provider<CountFinishedWorkouts>(
  (ref) => CountFinishedWorkouts(ref.watch(trainingStatsRepositoryProvider)),
);

final countFinishedWorkoutsThisMonthProvider =
    Provider<CountFinishedWorkoutsThisMonth>(
  (ref) => CountFinishedWorkoutsThisMonth(
    ref.watch(trainingStatsRepositoryProvider),
  ),
);

/// Total de entrenos finalizados del usuario en sesión.
final totalWorkoutsProvider = FutureProvider<int>(
  (ref) => ref.watch(countFinishedWorkoutsProvider).call(),
);

final getCurrentStreakProvider = Provider<GetCurrentStreak>(
  (ref) => GetCurrentStreak(ref.watch(trainingStatsRepositoryProvider)),
);

/// Entrenos finalizados dentro del mes natural actual.
final workoutsThisMonthProvider = FutureProvider<int>(
  (ref) => ref.watch(countFinishedWorkoutsThisMonthProvider).call(),
);

/// Racha actual de semanas consecutivas con ≥3 entrenos finalizados.
final weeklyStreakProvider = FutureProvider<int>(
  (ref) => ref.watch(getCurrentStreakProvider).call(),
);
