/// Último entreno finalizado del usuario, para la tarjeta Entreno de Inicio.
/// Entidad pura de dominio, inmutable. Mínima a propósito: solo nombre + fecha
/// (lo único que muestra la tarjeta). El formato de la fecha relativa (`hoy`,
/// `ayer`...) es presentación y NO vive aquí.
class LastWorkout {
  const LastWorkout({required this.nombre, required this.fecha});

  /// Nombre de la sesión/rutina del workout.
  final String nombre;

  /// Fecha (local) del workout, sin componente horario.
  final DateTime fecha;
}
