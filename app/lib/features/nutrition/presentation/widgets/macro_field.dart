import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Campo numérico etiquetado para un macro (kcal, proteína, carbos, grasa).
///
/// Envuelve [AppTextField] con una etiqueta tenue encima (estilo `labelSmall`,
/// mayúsculas) y teclado numérico, para no repetir la misma estructura cuatro
/// veces en el formulario editable. Sin valores sueltos: todo del theme/tokens.
class MacroField extends StatelessWidget {
  const MacroField({
    super.key,
    required this.label,
    required this.controller,
    this.unit,
  });

  /// Etiqueta del macro (p. ej. "Proteína").
  final String label;

  final TextEditingController controller;

  /// Unidad opcional mostrada junto a la etiqueta (p. ej. "g", "kcal").
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final caption = unit == null ? label : '$label ($unit)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption.toUpperCase(), style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: controller,
          label: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autocorrect: false,
        ),
      ],
    );
  }
}
