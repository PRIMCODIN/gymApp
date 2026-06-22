/// Datos antropométricos editables del perfil (los seis campos del formulario
/// "Editar mis datos"). Value object de la capa domain: Dart puro.
///
/// Todos son opcionales: el usuario puede guardar dejando cualquiera vacío, lo
/// que se traduce en `null` (limpia la columna en BD). Los valores de [sex],
/// [activityLevel] y [goal] van en español, igual que en BD (los validan los
/// CHECK). `plan` y `kcalGoal` NO forman parte de este value object: el primero
/// no se edita nunca desde el cliente y el segundo tiene su propio flujo.
class PersonalData {
  const PersonalData({
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
  });

  final String? sex;
  final DateTime? birthDate;
  final int? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? goal;
}
