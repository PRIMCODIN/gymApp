import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/training_failure.dart';
import '../../domain/entities/exercise.dart';
import '../state/exercise_catalog_providers.dart';
import '../utils/muscle_groups.dart';

/// Abre el formulario de creación de un ejercicio personalizado en un diálogo.
/// [initialName] prerrellena el nombre (lo que el usuario buscó en el selector).
/// Devuelve el [Exercise] creado, o null si se cancela.
Future<Exercise?> showCreateCustomExerciseForm(
  BuildContext context, {
  String initialName = '',
}) {
  return showDialog<Exercise>(
    context: context,
    builder: (_) => CreateCustomExerciseForm(initialName: initialName),
  );
}

/// Formulario de alta de un ejercicio personalizado: nombre + grupo muscular de
/// una lista cerrada ([kMuscleGroups]). Al guardar llama a
/// [createCustomExerciseProvider], invalida el catálogo y devuelve el ejercicio
/// creado vía `Navigator.pop`.
class CreateCustomExerciseForm extends ConsumerStatefulWidget {
  const CreateCustomExerciseForm({super.key, this.initialName = ''});

  final String initialName;

  @override
  ConsumerState<CreateCustomExerciseForm> createState() =>
      _CreateCustomExerciseFormState();
}

class _CreateCustomExerciseFormState
    extends ConsumerState<CreateCustomExerciseForm> {
  late final TextEditingController _nombreController =
      TextEditingController(text: widget.initialName);

  /// Grupo muscular elegido (null = aún sin elegir).
  String? _grupoMuscular;
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _showSnackBar('Escribe un nombre para el ejercicio.');
      return;
    }
    final grupo = _grupoMuscular;
    if (grupo == null) {
      _showSnackBar('Elige un grupo muscular.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final created =
          await ref.read(createCustomExerciseProvider).call(nombre, grupo);
      // Refresca el catálogo para que el nuevo ejercicio aparezca en el selector.
      ref.invalidate(exerciseCatalogProvider);
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } on TrainingFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('No se pudo crear el ejercicio. Inténtalo de nuevo.');
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
    final maxHeight =
        media.size.height - AppSpacing.l * 2 - media.viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: AppSpacing.l + media.viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nuevo ejercicio', style: textTheme.labelLarge),
                    IconButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: context.palette.textSecondary,
                      ),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Text('NOMBRE', style: textTheme.labelSmall),
                const SizedBox(height: AppSpacing.s),
                AppTextField(
                  controller: _nombreController,
                  label: 'Ej. Press inclinado en multipower',
                  enabled: !_isSaving,
                ),
                const SizedBox(height: AppSpacing.l),
                Text('GRUPO MUSCULAR', style: textTheme.labelSmall),
                const SizedBox(height: AppSpacing.s),
                _MuscleGroupSelector(
                  selected: _grupoMuscular,
                  enabled: !_isSaving,
                  onSelected: (group) =>
                      setState(() => _grupoMuscular = group),
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  label: 'Crear ejercicio',
                  isLoading: _isSaving,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rejilla de chips de la lista cerrada de grupos musculares. Solo uno activo.
class _MuscleGroupSelector extends StatelessWidget {
  const _MuscleGroupSelector({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final group in kMuscleGroups)
          ChoiceChip(
            label: Text(muscleGroupLabel(group)),
            selected: selected == group,
            onSelected: enabled ? (_) => onSelected(group) : null,
            backgroundColor: palette.surfaceElevated,
            selectedColor: palette.accentTraining,
          ),
      ],
    );
  }
}
