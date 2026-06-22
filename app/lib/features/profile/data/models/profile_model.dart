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

  /// Default de `objetivo_kcal_diario` cuando aún no hay valor (coincide con BD).
  static const int _defaultKcalGoal = 2000;

  /// Construye el modelo desde una fila de `profiles` (SELECT). Tolera nulls:
  /// `kcalGoal` cae al default; el resto se queda en `null` (perfil sin rellenar).
  factory ProfileModel.fromRow(Map<String, dynamic> row) {
    return ProfileModel(
      name: row['nombre'] as String?,
      kcalGoal: _readInt(row['objetivo_kcal_diario']) ?? _defaultKcalGoal,
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

  /// Mapa para actualizar los seis datos antropométricos. Un campo `null` se
  /// envía como `null` para limpiar la columna. **Nunca incluye `plan`** (lo
  /// revertiría el trigger `lock_plan`). `fecha_nacimiento` va como `YYYY-MM-DD`.
  static Map<String, dynamic> personalDataUpdate(PersonalData data) {
    return {
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
