import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/routine_supabase_datasource.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/usecases/create_routine.dart';
import '../../domain/usecases/delete_routine.dart';
import '../../domain/usecases/fetch_routine_detail.dart';
import '../../domain/usecases/fetch_routines.dart';
import '../../domain/usecases/update_routine.dart';

/// Cableado de dependencias de las rutinas (data → domain), expuesto a
/// presentation vía Riverpod. Mismo patrón que `exercise_catalog_providers.dart`:
/// lectura directa a Supabase (sin n8n), expuesta como `FutureProvider` que
/// entrega un `AsyncValue` (cubre loading/error/data por diseño).

final routineSupabaseDataSourceProvider =
    Provider<RoutineSupabaseDataSource>((ref) {
  return RoutineSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepositoryImpl(ref.watch(routineSupabaseDataSourceProvider));
});

final fetchRoutinesProvider = Provider<FetchRoutines>(
  (ref) => FetchRoutines(ref.watch(routineRepositoryProvider)),
);

final fetchRoutineDetailProvider = Provider<FetchRoutineDetail>(
  (ref) => FetchRoutineDetail(ref.watch(routineRepositoryProvider)),
);

final createRoutineProvider = Provider<CreateRoutine>(
  (ref) => CreateRoutine(ref.watch(routineRepositoryProvider)),
);

final updateRoutineProvider = Provider<UpdateRoutine>(
  (ref) => UpdateRoutine(ref.watch(routineRepositoryProvider)),
);

final deleteRoutineProvider = Provider<DeleteRoutine>(
  (ref) => DeleteRoutine(ref.watch(routineRepositoryProvider)),
);

/// Lista de rutinas del usuario (cabeceras con items para el resumen). La página
/// la observa; tras crear/editar/borrar se invalida para recomponerla.
final routinesListProvider = FutureProvider<List<Routine>>((ref) {
  return ref.watch(fetchRoutinesProvider).call();
});

/// Detalle de una rutina (con sus items), cargado por `routineId`. Lo usa el
/// editor al abrir una rutina existente y la lista al pulsar "Empezar".
final routineDetailProvider =
    FutureProvider.family<Routine, int>((ref, routineId) {
  return ref.watch(fetchRoutineDetailProvider).call(routineId);
});
