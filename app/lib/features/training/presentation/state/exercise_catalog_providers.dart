import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/exercise_supabase_datasource.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/create_custom_exercise.dart';
import '../../domain/usecases/fetch_exercise_catalog.dart';

/// Providers del catálogo de ejercicios de Entreno.
///
/// Cadena de dependencias datasource -> repo -> usecase -> provider, igual que
/// `features/nutrition/presentation/state/daily_nutrition_providers.dart`. La
/// lectura es directa a Supabase (sin n8n) y se expone como `FutureProvider`, que
/// entrega un `AsyncValue` y cubre por diseño loading/error/data.

final exerciseSupabaseDataSourceProvider =
    Provider<ExerciseSupabaseDataSource>((ref) {
  return ExerciseSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(exerciseSupabaseDataSourceProvider));
});

final fetchExerciseCatalogProvider = Provider<FetchExerciseCatalog>(
  (ref) => FetchExerciseCatalog(ref.watch(exerciseRepositoryProvider)),
);

final createCustomExerciseProvider = Provider<CreateCustomExercise>(
  (ref) => CreateCustomExercise(ref.watch(exerciseRepositoryProvider)),
);

/// Catálogo de ejercicios visibles (globales + propios), ordenado por nombre.
/// El selector lo observa; tras crear un ejercicio personalizado se invalida
/// para que la lista se recomponga con el nuevo ejercicio.
final exerciseCatalogProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(fetchExerciseCatalogProvider).call();
});
