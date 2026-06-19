import '../../domain/entities/food_log_entry.dart';
import '../../domain/entities/nutrition_estimate.dart';
import 'food_log_model.dart';

/// DTO de [FoodLogEntry]: mapea una fila de `food_logs` (SELECT) a la entidad de
/// lectura. El `id` y la `fecha` vienen siempre rellenos en un SELECT, por eso
/// aquí son no-nullables. La tolerancia numérica de los macros se reutiliza de
/// [FoodLogModel.readNumber].
class FoodLogEntryModel extends FoodLogEntry {
  const FoodLogEntryModel({
    required super.id,
    required super.fecha,
    required super.descripcion,
    required super.nutrition,
  });

  factory FoodLogEntryModel.fromRow(Map<String, dynamic> row) {
    return FoodLogEntryModel(
      id: (row['id'] as num).toInt(),
      fecha: DateTime.parse(row['fecha'] as String),
      descripcion: (row['descripcion'] as String?) ?? '',
      nutrition: NutritionEstimate(
        kcal: FoodLogModel.readNumber(row['kcal']),
        proteina: FoodLogModel.readNumber(row['proteina']),
        carbos: FoodLogModel.readNumber(row['carbos']),
        grasa: FoodLogModel.readNumber(row['grasa']),
      ),
    );
  }
}
