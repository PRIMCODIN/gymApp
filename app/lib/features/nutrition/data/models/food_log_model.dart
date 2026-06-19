import '../../domain/entities/food_log.dart';

/// DTO de [FoodLog]: añade la serialización para el INSERT en Supabase.
class FoodLogModel extends FoodLog {
  const FoodLogModel({required super.descripcion, required super.nutrition});

  FoodLogModel.fromEntity(FoodLog log)
      : super(descripcion: log.descripcion, nutrition: log.nutrition);

  /// Mapa para insertar en la tabla `food_logs`. `fecha` (default hoy) y
  /// `created_at` los rellena la BD, por eso no se envían. `kcal` es `integer`
  /// en la BD; los macros son `numeric`.
  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'descripcion': descripcion,
      'kcal': nutrition.kcal.round(),
      'proteina': nutrition.proteina,
      'carbos': nutrition.carbos,
      'grasa': nutrition.grasa,
    };
  }
}
