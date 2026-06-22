/// Calcula la edad (años cumplidos) a partir de la fecha de nacimiento, en el
/// momento de render. El perfil NO almacena la edad, solo `fecha_nacimiento`
/// (ver `specs/perfil.md`). Devuelve null si no hay fecha.
int? ageFromBirthDate(DateTime? birthDate, {DateTime? now}) {
  if (birthDate == null) return null;
  final today = now ?? DateTime.now();
  var age = today.year - birthDate.year;
  // Resta un año si aún no ha llegado el cumpleaños de este año.
  final hadBirthdayThisYear = today.month > birthDate.month ||
      (today.month == birthDate.month && today.day >= birthDate.day);
  if (!hadBirthdayThisYear) age--;
  return age < 0 ? null : age;
}
