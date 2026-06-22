import 'package:flutter/material.dart';

/// Campo de texto reutilizable sobre `surfaceElevated`, con icono a la izquierda,
/// label/placeholder tenue, borde sutil y manejo de estado de error. Hereda su
/// estilo del `inputDecorationTheme` central; no define colores ni tamaños propios.
///
/// Para campos de contraseña, pasar [isPassword] = `true`: el widget gestiona
/// internamente el ocultado del texto y muestra un icono de ojo para
/// mostrar/ocultar. No usar [obscureText] junto con [isPassword].
///
/// Si se pasa [validator], el campo participa en un `Form` (renderiza un
/// `TextFormField` y muestra el error que devuelva el validador). En ese caso
/// [errorText] se ignora: ambos son mutuamente excluyentes (uno manual, otro por
/// `Form`).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.errorText,
    this.obscureText = false,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
    this.autocorrect = true,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController controller;

  /// Texto del placeholder (se muestra como `hintText`, no como label flotante).
  final String label;

  /// Icono a la izquierda del campo (línea fina, set Material).
  final IconData? prefixIcon;

  /// Mensaje de error a mostrar bajo el campo (null = sin error).
  final String? errorText;

  /// Oculta el texto (para campos sensibles que no necesitan toggle de ojo).
  final bool obscureText;

  /// Campo de contraseña: oculta el texto y añade un icono de ojo para alternar.
  final bool isPassword;

  final bool enabled;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Validador de formulario. Si se pasa, el campo se renderiza como
  /// `TextFormField` y participa en el `Form` que lo contenga. Si es null, el
  /// campo es un `TextField` simple (y usa [errorText] manual).
  final FormFieldValidator<String>? validator;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword || widget.obscureText;

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final isHidden = widget.isPassword ? _obscured : widget.obscureText;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    final decoration = InputDecoration(
      hintText: widget.label,
      // Con validador, el error lo gestiona el `Form`; se ignora [errorText].
      errorText: widget.validator == null ? widget.errorText : null,
      prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      suffixIcon: widget.isPassword
          ? IconButton(
              onPressed: widget.enabled ? _toggleObscured : null,
              icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
              tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
            )
          : null,
    );

    // Con validador, participa en un `Form` (TextFormField); sin él, es un
    // TextField simple. La decoración y el estilo son idénticos en ambos casos.
    if (widget.validator != null) {
      return TextFormField(
        controller: widget.controller,
        obscureText: isHidden,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        autocorrect: widget.autocorrect,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: style,
        decoration: decoration,
      );
    }

    return TextField(
      controller: widget.controller,
      obscureText: isHidden,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      style: style,
      decoration: decoration,
    );
  }
}
