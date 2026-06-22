import '../../domain/entities/personal_data.dart';
import '../../domain/entities/profile.dart';

/// DTO de [Profile]: añade la serialización con Supabase (lectura de fila y
/// mapas de UPDATE). El mapeo BD↔Dart vive aquí (data layer), según el spec:
/// columnas en español, campos en inglés. Los valores de enum se conservan tal
/// cual (en español), que es lo que validan los CHECK de BD.
class ProfileModel extends Profile {
  const ProfileModel({
    required super.name,
    required super.kcalGoal,
    required super.plan,
    required super.sex,
    required super.birthDate,
    required super.heightCm,
    required super.weightKg,
    required super.activityLevel,
    required super.goal,
  });

  /// Construye el modelo desde una fila de `profiles` (SELECT). Tolera nulls:
  /// todos los campos opcionales se quedan en `null` cuando el perfil no los ha
  /// rellenado (incluido `kcalGoal`: `null` = objetivo sin fijar, no un 2000).
  factory ProfileModel.fromRow(Map<String, dynamic> row) {
    return ProfileModel(
      name: row['nombre'] as String?,
      kcalGoal: _readInt(row['objetivo_kcal_diario']),
      plan: (row['plan'] as String?) ?? 'free',
      sex: row['sexo'] as String?,
      birthDate: _readDate(row['fecha_nacimiento']),
      heightCm: _readInt(row['altura_cm']),
      weightKg: _readDouble(row['peso_kg']),
      activityLevel: row['nivel_actividad'] as String?,
      goal: row['objetivo'] as String?,
    );
  }

  /// Mapa para actualizar solo el objetivo de kcal. Nunca toca `plan`.
  static Map<String, dynamic> calorieGoalUpdate(int goal) {
    return {'objetivo_kcal_diario': goal};
  }

  /// Mapa para actualizar los datos editables del perfil. `nombre` es obligatorio
  /// (ya viene *trimmeado* y no vacío desde la UI); el resto, un `null` se envía
  /// como `null` para limpiar la columna. **Nunca incluye `plan`** (lo revertiría
  /// el trigger `lock_plan`). `fecha_nacimiento` va como `YYYY-MM-DD`.
  static Map<String, dynamic> personalDataUpdate(PersonalData data) {
    return {
      'nombre': data.name,
      'sexo': data.sex,
      'fecha_nacimiento': _formatDate(data.birthDate),
      'altura_cm': data.heightCm,
      'peso_kg': data.weightKg,
      'nivel_actividad': data.activityLevel,
      'objetivo': data.goal,
    };
  }

  /// Lee un entero de la BD (`integer`/`smallint`) tolerando null, `num` y String.
  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Lee un decimal de la BD (`numeric`) tolerando null, `num` y String (con
  /// coma o punto decimal).
  static double? _readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  /// Parsea una `date` de la BD (`YYYY-MM-DD` o ISO) a [DateTime] local sin hora.
  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return null;
  }

  /// Formatea una fecha local como `YYYY-MM-DD` para la columna `date`. Null se
  /// mantiene null (limpia la columna).
  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
