import '../../domain/entities/nutrition_estimate.dart';
import '../nutrition_failure.dart';

/// DTO de [NutritionEstimate]: añade el parseo de la respuesta JSON de n8n.
///
/// n8n devuelve las claves en español: `{ "kcal", "proteina", "carbos", "grasa" }`,
/// con valores numéricos. El mapeo a la entidad (nombres en inglés) se hace aquí.
class NutritionEstimateModel extends NutritionEstimate {
  const NutritionEstimateModel({
    required super.kcal,
    required super.proteina,
    required super.carbos,
    required super.grasa,
  });

  factory NutritionEstimateModel.fromJson(Map<String, dynamic> json) {
    return NutritionEstimateModel(
      kcal: _readNumber(json, 'kcal'),
      proteina: _readNumber(json, 'proteina'),
      carbos: _readNumber(json, 'carbos'),
      grasa: _readNumber(json, 'grasa'),
    );
  }

  /// Lee un campo numérico tolerando enteros, decimales o numéricos en texto.
  /// Si falta o no es convertible, lanza [NutritionFailure] (respuesta inválida).
  static double _readNumber(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
    throw const NutritionFailure('La respuesta del servidor no es válida.');
  }
}
