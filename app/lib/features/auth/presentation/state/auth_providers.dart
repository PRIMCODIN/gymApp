import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/watch_auth_state.dart';

/// Cableado de dependencias de la feature auth (data → domain), expuesto a la
/// capa de presentation vía Riverpod.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remote);
});

final signInProvider = Provider<SignIn>(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);

final signUpProvider = Provider<SignUp>(
  (ref) => SignUp(ref.watch(authRepositoryProvider)),
);

final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetProvider = Provider<SendPasswordReset>(
  (ref) => SendPasswordReset(ref.watch(authRepositoryProvider)),
);

final watchAuthStateProvider = Provider<WatchAuthState>(
  (ref) => WatchAuthState(ref.watch(authRepositoryProvider)),
);

/// Estado de sesión reactivo. El `AuthGate` lo observa para decidir qué pantalla
/// mostrar. Emite el usuario actual en cada login/logout y `null` si no hay sesión.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(watchAuthStateProvider).call();
});
