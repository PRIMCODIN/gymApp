/// Rendimiento de un set en la ÚLTIMA sesión finalizada con un ejercicio.
///
/// Entidad de LECTURA para la columna PREVIOUS estilo Hevy: el set Nº del
/// ejercicio en la sesión actual muestra lo que se hizo en el set Nº de la última
/// vez. `reps`/`peso` son nullables porque ese set pasado pudo guardarse a medias.
/// Dart puro: sin Flutter ni Supabase.
class PreviousSetPerformance {
  const PreviousSetPerformance({
    required this.numSet,
    this.reps,
    this.peso,
  });

  final int numSet;
  final int? reps;
  final double? peso;
}
