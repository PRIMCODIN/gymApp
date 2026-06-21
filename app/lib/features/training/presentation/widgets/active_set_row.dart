import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Fila de un set dentro de la tabla de un ejercicio, estilo Hevy:
/// `[SET nº] [PREVIOUS] [KG] [REPS] [✓]`. Deslizar a la izquierda borra el set.
///
/// Es `StatefulWidget` con sus propios `TextEditingController` (sembrados una vez)
/// para no perder el cursor mientras se escribe. Debe recibir una `Key` estable
/// basada en `ActiveSet.uid` desde el padre: así Flutter no reaprovecha el estado
/// de otra fila al editar/renumerar.
class ActiveSetRow extends StatefulWidget {
  const ActiveSetRow({
    super.key,
    required this.uid,
    required this.numSet,
    required this.reps,
    required this.peso,
    required this.completado,
    required this.previousLabel,
    required this.onRepsChanged,
    required this.onPesoChanged,
    required this.onToggle,
    required this.onRemove,
  });

  /// Identidad estable del set ([ActiveSet.uid]), para la `Key` del `Dismissible`.
  final int uid;

  final int numSet;
  final int? reps;
  final double? peso;
  final bool completado;

  /// Texto ya formateado del rendimiento anterior de este set ("60 kg × 8",
  /// "—" si no hay histórico, "…" mientras carga).
  final String previousLabel;

  final ValueChanged<int?> onRepsChanged;
  final ValueChanged<double?> onPesoChanged;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  State<ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<ActiveSetRow> {
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

    return Dismissible(
      key: ValueKey('set-dismiss-${widget.uid}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.m),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.background),
      ),
      child: Container(
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
            Expanded(
              flex: 3,
              child: Text(
                widget.previousLabel,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
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
              onPressed: widget.onToggle,
              tooltip: widget.completado
                  ? 'Marcar como pendiente'
                  : 'Marcar como completado',
              icon: Icon(
                widget.completado
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: widget.completado
                    ? palette.accentTraining
                    : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
