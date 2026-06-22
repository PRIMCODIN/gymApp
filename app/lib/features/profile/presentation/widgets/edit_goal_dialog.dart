import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../nutrition/presentation/state/daily_nutrition_providers.dart';
import '../../data/profile_failure.dart';
import '../state/profile_providers.dart';

/// Abre el editor del objetivo de kcal en un diálogo. [current] prerrellena el
/// campo con el valor actual, o lo deja vacío si el objetivo aún no está fijado
/// (`null`).
Future<void> showEditGoalDialog(
  BuildContext context, {
  required int? current,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => EditGoalDialog(current: current),
  );
}

/// Diálogo para editar `objetivo_kcal_diario`: un único campo numérico. Al
/// guardar, llama al caso de uso e invalida [profileProvider] (refresca esta
/// pantalla) y [dailyCalorieGoalProvider] (refresca la barra de Nutrición, que
/// lee el mismo dato). Errores → SnackBar vía [ProfileFailure].
class EditGoalDialog extends ConsumerStatefulWidget {
  const EditGoalDialog({super.key, required this.current});

  final int? current;

  @override
  ConsumerState<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends ConsumerState<EditGoalDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.current?.toString() ?? '');
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final goal = int.tryParse(_controller.text.trim());
    if (goal == null || goal <= 0) {
      _showSnackBar('Introduce un objetivo de kcal válido.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      await ref.read(updateCalorieGoalProvider).call(goal);
      ref.invalidate(profileProvider);
      // El objetivo lo lee también Nutrición; refresca su barra de calorías.
      ref.invalidate(dailyCalorieGoalProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('No se pudo guardar el objetivo. Inténtalo de nuevo.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: AppSpacing.l + media.viewInsets.bottom,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Editar objetivo', style: textTheme.labelLarge),
                IconButton(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: context.palette.textSecondary),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text('OBJETIVO DIARIO (KCAL)', style: textTheme.labelSmall),
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              controller: _controller,
              label: 'Ej. 2000',
              prefixIcon: Icons.local_fire_department_outlined,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSave(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: 'Guardar',
              variant: AppButtonVariant.nutrition,
              isLoading: _isSaving,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
