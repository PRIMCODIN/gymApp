import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/profile_supabase_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_calorie_goal.dart';
import '../../domain/usecases/update_personal_data.dart';

/// Cableado de dependencias de la feature perfil (data → domain), expuesto a la
/// capa de presentation vía Riverpod. Mismo patrón que `auth_providers.dart` y
/// `daily_nutrition_providers.dart`.

final profileSupabaseDataSourceProvider =
    Provider<ProfileSupabaseDataSource>((ref) {
  return ProfileSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileSupabaseDataSourceProvider));
});

final getProfileProvider = Provider<GetProfile>(
  (ref) => GetProfile(ref.watch(profileRepositoryProvider)),
);

final updateCalorieGoalProvider = Provider<UpdateCalorieGoal>(
  (ref) => UpdateCalorieGoal(ref.watch(profileRepositoryProvider)),
);

final updatePersonalDataProvider = Provider<UpdatePersonalData>(
  (ref) => UpdatePersonalData(ref.watch(profileRepositoryProvider)),
);

/// Perfil del usuario en sesión. Lectura directa a Supabase, expuesta como
/// `FutureProvider` (entrega un `AsyncValue` y cubre loading/error/data). Tras
/// editar el objetivo o los datos, se invalida para que la pantalla se recomponga.
final profileProvider = FutureProvider<Profile>((ref) {
  return ref.watch(getProfileProvider).call();
});
