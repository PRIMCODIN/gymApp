import 'package:flutter/material.dart';

/// Campo de texto reutilizable sobre `surfaceElevated`, con label tenue y manejo
/// de estado de error. Hereda su estilo del `inputDecorationTheme` central; no
/// define colores ni tamaños propios.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String label;

  /// Mensaje de error a mostrar bajo el campo (null = sin error).
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
      ),
    );
  }
}
