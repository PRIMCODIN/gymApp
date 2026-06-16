import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Contexto semántico de la barra de progreso: determina el color del acento.
enum AppProgressContext {
  /// Calorías / nutrición (naranja).
  calories,

  /// Entreno (teal).
  training,
}

/// Barra de progreso reutilizable. El color sale del contexto a través de la
/// [AppPalette]; el track se apoya en `surfaceElevated`. Sin hex sueltos.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.context = AppProgressContext.calories,
    this.height = 10,
  });

  /// Progreso en el rango [0, 1].
  final double value;
  final AppProgressContext context;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = switch (this.context) {
      AppProgressContext.calories => palette.accentNutrition,
      AppProgressContext.training => palette.accentTraining,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: palette.surfaceElevated,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
