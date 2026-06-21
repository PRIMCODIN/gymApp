import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Fila editable de un set en el modo edición del detalle: `[nº] [KG] [REPS] [🗑]`.
///
/// Es `StatefulWidget` con sus propios `TextEditingController` (sembrados una vez)
/// para no perder el cursor mientras se escribe. Debe recibir una `Key` estable
/// basada en el `uid` del set desde el padre, para que Flutter no reaproveche el
/// estado de otra fila al editar/renumerar. Mismo patrón que `ActiveSetRow`, pero
/// sin PREVIOUS ni toggle de completado (en D2 solo se editan kg/reps y se borra).
class WorkoutEditSetRow extends StatefulWidget {
  const WorkoutEditSetRow({
    super.key,
    required this.numSet,
    required this.reps,
    required this.peso,
    required this.completado,
    required this.onRepsChanged,
    required this.onPesoChanged,
    required this.onRemove,
  });

  final int numSet;
  final int? reps;
  final double? peso;

  /// Se preserva (no editable en D2); solo tiñe la fila como referencia visual.
  final bool completado;

  final ValueChanged<int?> onRepsChanged;
  final ValueChanged<double?> onPesoChanged;
  final VoidCallback onRemove;

  @override
  State<WorkoutEditSetRow> createState() => _WorkoutEditSetRowState();
}

class _WorkoutEditSetRowState extends State<WorkoutEditSetRow> {
  late final TextEditingController _pesoController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _pesoController = TextEditingController(text: _pesoText(widget.peso));
    _repsController = TextEditingController(text: widget.reps?.toString() ?? '');
    _pesoController.addListener(_notifyPeso);
    _repsController.addListener(_notifyReps);
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _notifyPeso() {
    final text = _pesoController.text.trim().replaceAll(',', '.');
    widget.onPesoChanged(text.isEmpty ? null : double.tryParse(text));
  }

  void _notifyReps() {
    final text = _repsController.text.trim();
    widget.onRepsChanged(text.isEmpty ? null : int.tryParse(text));
  }

  /// Peso a texto: sin decimales si es entero (60), con ellos si no (62.5).
  String _pesoText(double? peso) {
    if (peso == null) return '';
    if (peso == peso.roundToDouble()) return peso.toStringAsFixed(0);
    return peso.toString();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: widget.completado
            ? palette.accentTraining.withValues(alpha: 0.12)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${widget.numSet}',
              textAlign: TextAlign.center,
              style: textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: AppTextField(
              controller: _pesoController,
              label: 'kg',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: AppTextField(
              controller: _repsController,
              label: 'reps',
              keyboardType: TextInputType.number,
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            tooltip: 'Borrar set',
            icon: Icon(Icons.delete_outline, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
