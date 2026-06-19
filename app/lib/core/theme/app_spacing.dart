/// Escala de espaciado del design system (`specs/design-system.md`).
///
/// Generosidad: el minimalismo se apoya en el aire. Toda pantalla y componente
/// usa estos tokens; nunca números sueltos.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

/// Tokens de forma (radios de esquina).
abstract final class AppRadius {
  /// Radio generoso para tarjetas (`specs/design-system.md`, ~16px).
  static const double card = 16;

  /// Radio para inputs, botones y controles pequeños (12px, según el mockup).
  static const double input = 12;
}
