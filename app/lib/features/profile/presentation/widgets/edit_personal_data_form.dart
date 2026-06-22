import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/profile_failure.dart';
import '../../domain/entities/personal_data.dart';
import '../../domain/entities/profile.dart';
import '../state/profile_providers.dart';
import '../utils/profile_options.dart';

/// Abre el formulario "Editar mis datos" en un diálogo, precargado con los
/// valores actuales de [profile].
Future<void> showEditPersonalDataForm(
  BuildContext context, {
  required Profile profile,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => EditPersonalDataForm(profile: profile),
  );
}

/// Formulario único de edición del perfil. El nombre es obligatorio; el resto de
/// campos son opcionales (guardar vacío → null, limpia la columna). La validación
/// (nombre obligatorio, altura 80–260, peso 25–400) vive en los `validator` de un
/// `Form` y se muestra como `errorText` bajo cada campo; el guardado llama a
/// `validate()` y aborta si falla. Al guardar con éxito, llama al caso de uso e
/// invalida [profileProvider]. Los errores de guardado → SnackBar vía
/// [ProfileFailure].
class EditPersonalDataForm extends ConsumerStatefulWidget {
  const EditPersonalDataForm({super.key, required this.profile});

  final Profile profile;

  @override
  ConsumerState<EditPersonalDataForm> createState() =>
      _EditPersonalDataFormState();
}

class _EditPersonalDataFormState extends ConsumerState<EditPersonalDataForm> {
  final _formKey = GlobalKey<FormState>();

  // Nombre: se abre vacío si la fila actual no tiene nombre (null).
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.name ?? '',
  );
  late final TextEditingController _heightController = TextEditingController(
    text: widget.profile.heightCm?.toString() ?? '',
  );
  late final TextEditingController _weightController = TextEditingController(
    text: _formatWeight(widget.profile.weightKg),
  );

  late String? _sex = widget.profile.sex;
  late DateTime? _birthDate = widget.profile.birthDate;
  late String? _activityLevel = widget.profile.activityLevel;
  late String? _goal = widget.profile.goal;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Valida el nombre: obligatorio (no vacío tras *trim*).
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  /// Valida la altura: opcional, pero si hay texto debe ser un entero en 80–260.
  String? _validateHeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final height = int.tryParse(text);
    if (height == null || height < 80 || height > 260) {
      return 'La altura debe estar entre 80 y 260 cm.';
    }
    return null;
  }

  /// Valida el peso: opcional, pero si hay texto debe ser un decimal en 25–400
  /// (tolera coma decimal).
  String? _validateWeight(String? value) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty) return null;
    final weight = double.tryParse(text);
    if (weight == null || weight < 25 || weight > 400) {
      return 'El peso debe estar entre 25 y 400 kg.';
    }
    return null;
  }

  /// Formatea el peso sin decimales superfluos (72.0 → "72", 72.5 → "72.5").
  String _formatWeight(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) {
      setState(
        () => _birthDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  Future<void> _onSave() async {
    // Valida nombre (obligatorio) y rangos de altura/peso vía los validator del
    // Form; los errores aparecen como errorText bajo cada campo.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Tras validar, el texto (no vacío) ya es parseable y está en rango.
    final heightText = _heightController.text.trim();
    final heightCm = heightText.isEmpty ? null : int.parse(heightText);

    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weightKg = weightText.isEmpty ? null : double.parse(weightText);

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final data = PersonalData(
        name: _nameController.text.trim(),
        sex: _sex,
        birthDate: _birthDate,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: _activityLevel,
        goal: _goal,
      );
      await ref.read(updatePersonalDataProvider).call(data);
      ref.invalidate(profileProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ProfileFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('No se pudieron guardar tus datos. Inténtalo de nuevo.');
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Editar mis datos', style: textTheme.labelLarge),
                      IconButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: context.palette.textSecondary,
                        ),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Nombre (obligatorio) ---
                  Text('NOMBRE', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  AppTextField(
                    controller: _nameController,
                    label: 'Ej. Víctor',
                    prefixIcon: Icons.person_outline,
                    enabled: !_isSaving,
                    textInputAction: TextInputAction.next,
                    validator: _validateName,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Sexo ---
                  Text('SEXO', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  _ChipSelector(
                    values: kSexes,
                    labelOf: sexLabel,
                    selected: _sex,
                    enabled: !_isSaving,
                    onSelected: (value) => setState(() => _sex = value),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Fecha de nacimiento ---
                  Text('FECHA DE NACIMIENTO', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  _BirthDateField(
                    date: _birthDate,
                    enabled: !_isSaving,
                    onTap: _pickBirthDate,
                    onClear: () => setState(() => _birthDate = null),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Altura ---
                  Text('ALTURA (CM)', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  AppTextField(
                    controller: _heightController,
                    label: 'Ej. 175',
                    prefixIcon: Icons.height,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    validator: _validateHeight,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Peso ---
                  Text('PESO (KG)', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  AppTextField(
                    controller: _weightController,
                    label: 'Ej. 72.5',
                    prefixIcon: Icons.monitor_weight_outlined,
                    enabled: !_isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autocorrect: false,
                    validator: _validateWeight,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Nivel de actividad ---
                  Text('NIVEL DE ACTIVIDAD', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  _ChipSelector(
                    values: kActivityLevels,
                    labelOf: activityLevelLabel,
                    selected: _activityLevel,
                    enabled: !_isSaving,
                    onSelected: (value) =>
                        setState(() => _activityLevel = value),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  // --- Objetivo ---
                  Text('OBJETIVO', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  _ChipSelector(
                    values: kGoals,
                    labelOf: goalLabel,
                    selected: _goal,
                    enabled: !_isSaving,
                    onSelected: (value) => setState(() => _goal = value),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: 'Guardar',
                    isLoading: _isSaving,
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selector de chips de una lista cerrada. Permite deseleccionar (tocar el chip
/// activo) para dejar el campo vacío (→ null). Mismo patrón visual que el
/// selector de grupos musculares de entreno.
class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<String> values;
  final String Function(String) labelOf;
  final String? selected;
  final bool enabled;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text(labelOf(value)),
            selected: selected == value,
            // Tocar el chip activo lo deselecciona (vuelve a null).
            onSelected: enabled
                ? (isSelected) => onSelected(isSelected ? value : null)
                : null,
            backgroundColor: palette.surfaceElevated,
            selectedColor: palette.accentNutrition,
          ),
      ],
    );
  }
}

/// Campo tipo "input" que abre el date picker al tocarlo. Muestra la fecha
/// elegida o un placeholder; si hay fecha, ofrece limpiarla (→ null).
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.date,
    required this.enabled,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? date;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final hasDate = date != null;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.s),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.s),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: palette.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                hasDate ? _formatDate(date!) : 'Selecciona una fecha',
                style: textTheme.bodySmall?.copyWith(
                  color: hasDate
                      ? Theme.of(context).colorScheme.onSurface
                      : palette.textTertiary,
                ),
              ),
            ),
            if (hasDate)
              IconButton(
                onPressed: enabled ? onClear : null,
                icon: Icon(Icons.close, color: palette.textSecondary, size: 18),
                tooltip: 'Quitar fecha',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  /// Fecha legible `DD/MM/AAAA`.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
