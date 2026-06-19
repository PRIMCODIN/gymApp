import '../../domain/entities/food_log.dart';
import '../../domain/entities/nutrition_estimate.dart';

/// DTO de [FoodLog]: añade la serialización con Supabase (INSERT y lectura).
class FoodLogModel extends FoodLog {
  const FoodLogModel({required super.descripcion, required super.nutrition});

  FoodLogModel.fromEntity(FoodLog log)
      : super(descripcion: log.descripcion, nutrition: log.nutrition);

  /// Construye el modelo desde una fila de `food_logs` (SELECT). Las columnas de
  /// macros son `nullable` en la BD; un null se trata como 0.
  factory FoodLogModel.fromRow(Map<String, dynamic> row) {
    return FoodLogModel(
      descripcion: (row['descripcion'] as String?) ?? '',
      nutrition: NutritionEstimate(
        kcal: readNumber(row['kcal']),
        proteina: readNumber(row['proteina']),
        carbos: readNumber(row['carbos']),
        grasa: readNumber(row['grasa']),
      ),
    );
  }

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

  /// Mapa para actualizar una fila existente de `food_logs`. Solo las columnas
  /// editables por el usuario; `user_id`, `fecha` y `created_at` no se tocan.
  Map<String, dynamic> toUpdate() {
    return {
      'descripcion': descripcion,
      'kcal': nutrition.kcal.round(),
      'proteina': nutrition.proteina,
      'carbos': nutrition.carbos,
      'grasa': nutrition.grasa,
    };
  }

  /// Lee un valor numérico de la BD (`integer`/`numeric`) tolerando null y
  /// representaciones como `String`. Un dato ausente cuenta como 0. Público para
  /// reutilizarlo en otros DTO de lectura (p. ej. [FoodLogEntryModel]).
  static double readNumber(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }
}
