import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/http_client_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/food_log_supabase_datasource.dart';
import '../../data/datasources/n8n_meal_remote_datasource.dart';
import '../../data/nutrition_failure.dart';
import '../../data/repositories/food_log_repository_impl.dart';
import '../../data/repositories/meal_estimation_repository_impl.dart';
import '../../domain/entities/food_log.dart';
import '../../domain/entities/nutrition_estimate.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../../domain/repositories/meal_estimation_repository.dart';
import '../../domain/usecases/estimate_meal.dart';
import '../../domain/usecases/save_meal.dart';

/// Cableado de dependencias de la feature nutrición (data → domain), expuesto a
/// la capa de presentation vía Riverpod. Mismo patrón que `auth_providers.dart`.

final n8nMealRemoteDataSourceProvider = Provider<N8nMealRemoteDataSource>((ref) {
  return N8nMealRemoteDataSource(ref.watch(httpClientProvider));
});

final foodLogSupabaseDataSourceProvider =
    Provider<FoodLogSupabaseDataSource>((ref) {
  return FoodLogSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final mealEstimationRepositoryProvider =
    Provider<MealEstimationRepository>((ref) {
  return MealEstimationRepositoryImpl(
    ref.watch(n8nMealRemoteDataSourceProvider),
  );
});

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return FoodLogRepositoryImpl(ref.watch(foodLogSupabaseDataSourceProvider));
});

final estimateMealProvider = Provider<EstimateMeal>(
  (ref) => EstimateMeal(ref.watch(mealEstimationRepositoryProvider)),
);

final saveMealProvider = Provider<SaveMeal>(
  (ref) => SaveMeal(ref.watch(foodLogRepositoryProvider)),
);

/// Fase del flujo de registro de comida. La UI la usa para decidir qué mostrar
/// (formulario de descripción, formulario editable, spinners, feedback de éxito).
enum MealEntryStatus {
  /// Estado inicial: solo el campo de descripción.
  initial,

  /// Esperando la estimación de n8n.
  estimating,

  /// Estimación recibida: se muestra el formulario editable.
  estimated,

  /// Guardando en Supabase.
  saving,

  /// Guardado con éxito.
  saved,
}

/// Estado inmutable del flujo de registro de comida.
///
/// Cubre los tres estados de cada paso async (loading/error/data) mediante
/// [status] + [errorMessage], en lugar de un único `AsyncValue`, porque el flujo
/// tiene varias fases encadenadas (estimar → editar → guardar).
class MealEntryState {
  const MealEntryState({
    required this.status,
    this.estimate,
    this.errorMessage,
  });

  const MealEntryState.initial() : this(status: MealEntryStatus.initial);

  final MealEntryStatus status;

  /// Estimación devuelta por la IA, usada para prerrellenar el formulario editable.
  final NutritionEstimate? estimate;

  /// Mensaje de error legible (null = sin error). Nunca se silencia un fallo.
  final String? errorMessage;

  bool get isEstimating => status == MealEntryStatus.estimating;
  bool get isSaving => status == MealEntryStatus.saving;

  /// `true` desde que hay estimación hasta que se resetea (incluye guardando/guardado).
  bool get hasEstimate => estimate != null;

  MealEntryState copyWith({
    MealEntryStatus? status,
    NutritionEstimate? estimate,
    String? errorMessage,
  }) {
    return MealEntryState(
      status: status ?? this.status,
      estimate: estimate ?? this.estimate,
      errorMessage: errorMessage,
    );
  }
}

/// Orquesta el flujo estimar → editar → guardar.
///
/// La descripción y los valores editables viven en `TextEditingController`s de la
/// página; este controlador solo gestiona el estado de negocio y las llamadas a
/// los casos de uso. Traduce cualquier error a un mensaje en español
/// ([NutritionFailure]).
class MealEntryController extends Notifier<MealEntryState> {
  @override
  MealEntryState build() => const MealEntryState.initial();

  /// Pide la estimación a n8n a partir de la descripción.
  Future<void> estimate(String descripcion) async {
    state = state.copyWith(status: MealEntryStatus.estimating);
    try {
      final estimate = await ref
          .read(estimateMealProvider)
          .call(descripcion: descripcion.trim());
      state = MealEntryState(
        status: MealEntryStatus.estimated,
        estimate: estimate,
      );
    } catch (error) {
      state = MealEntryState(
        status: state.hasEstimate
            ? MealEntryStatus.estimated
            : MealEntryStatus.initial,
        estimate: state.estimate,
        errorMessage: _message(error),
      );
    }
  }

  /// Guarda en Supabase los valores CONFIRMADOS por el usuario (ya editados).
  Future<void> save({
    required String descripcion,
    required double kcal,
    required double proteina,
    required double carbos,
    required double grasa,
  }) async {
    state = state.copyWith(status: MealEntryStatus.saving);
    try {
      await ref.read(saveMealProvider).call(
            FoodLog(
              descripcion: descripcion.trim(),
              nutrition: NutritionEstimate(
                kcal: kcal,
                proteina: proteina,
                carbos: carbos,
                grasa: grasa,
              ),
            ),
          );
      state = state.copyWith(status: MealEntryStatus.saved);
    } catch (error) {
      state = MealEntryState(
        status: MealEntryStatus.estimated,
        estimate: state.estimate,
        errorMessage: _message(error),
      );
    }
  }

  /// Vuelve al estado inicial tras guardar (o para descartar y empezar de cero).
  void reset() => state = const MealEntryState.initial();

  String _message(Object error) => mapNutritionError(error).message;
}

final mealEntryControllerProvider =
    NotifierProvider<MealEntryController, MealEntryState>(
  MealEntryController.new,
);
