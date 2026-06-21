import '../../domain/entities/exercise.dart';

/// DTO de [Exercise]: mapea una fila de `exercises` (SELECT) a la entidad y
/// construye el payload de inserción de un ejercicio personalizado.
class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.userId,
    required super.nombre,
    required super.grupoMuscular,
  });

  /// Construye el modelo desde una fila de `exercises`. En un SELECT el `id`
  /// viene siempre relleno; `user_id` es null en los ejercicios globales.
  factory ExerciseModel.fromRow(Map<String, dynamic> row) {
    return ExerciseModel(
      id: (row['id'] as num).toInt(),
      userId: row['user_id'] as String?,
      nombre: (row['nombre'] as String?) ?? '',
      grupoMuscular: (row['grupo_muscular'] as String?) ?? '',
    );
  }

  /// Payload para crear un ejercicio personalizado: fuerza `user_id` al usuario en
  /// sesión. No envía `id` ni `created_at` (los pone la BD).
  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'nombre': nombre,
      'grupo_muscular': grupoMuscular,
    };
  }
}
