import 'package:flutter/material.dart';

/// Línea de pie "pregunta + enlace de acción" de las pantallas de auth
/// (ej. "¿No tienes cuenta? Regístrate"). El enlace usa el `textButtonTheme`
/// (teal); la pregunta va en gris tenue.
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: Theme.of(context).textTheme.labelMedium),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}
