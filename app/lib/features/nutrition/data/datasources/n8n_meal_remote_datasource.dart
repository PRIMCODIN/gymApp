import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/n8n_config.dart';
import '../models/nutrition_estimate_model.dart';
import '../nutrition_failure.dart';

/// Fuente de datos remota: estima la nutrición de una comida pegándole un POST
/// al webhook de n8n. n8n NO guarda nada; solo devuelve la estimación.
class N8nMealRemoteDataSource {
  const N8nMealRemoteDataSource(this._client);

  final http.Client _client;

  /// Tiempo máximo de espera: la IA puede tardar, pero no indefinidamente.
  static const Duration _timeout = Duration(seconds: 30);

  Future<NutritionEstimateModel> estimate({required String descripcion}) async {
    try {
      final response = await _client
          .post(
            N8nConfig.estimateMealUri(),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'descripcion': descripcion}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw const NutritionFailure(
          'No se pudo estimar la comida ahora mismo. Inténtalo más tarde.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const NutritionFailure('La respuesta del servidor no es válida.');
      }
      return NutritionEstimateModel.fromJson(decoded);
    } catch (error) {
      throw mapNutritionError(error);
    }
  }
}
