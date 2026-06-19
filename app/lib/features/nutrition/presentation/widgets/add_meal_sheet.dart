import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/nutrition_estimate.dart';
import '../state/daily_nutrition_providers.dart';
import '../state/meal_entry_controller.dart';
import 'macro_field.dart';

/// Abre el formulario de añadir comida en un diálogo centrado.
///
/// Resetea el controlador antes de abrir para empezar siempre en estado inicial.
/// El diálogo arranca compacto (solo la descripción) y se expande a casi pantalla
/// completa al estimar, según el estado de [MealEntryController].
Future<void> showAddMealSheet(BuildContext context, WidgetRef ref) {
  ref.read(mealEntryControllerProvider.notifier).reset();
  return showDialog<void>(
    context: context,
    builder: (_) => const AddMealSheet(),
  );
}

/// Contenido del diálogo de añadir comida: reúne el flujo existente
/// describir → estimar (IA vía n8n) → editar → guardar (Supabase). La descripción
/// y los valores editables viven en `TextEditingController`s locales; el estado de
/// negocio lo gestiona [MealEntryController].
class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  final _descripcionController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinaController = TextEditingController();
  final _carbosController = TextEditingController();
  final _grasaController = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    _kcalController.dispose();
    _proteinaController.dispose();
    _carbosController.dispose();
    _grasaController.dispose();
    super.dispose();
  }

  /// Vuelca la estimación de la IA en los campos editables del formulario.
  void _fillMacroFields(NutritionEstimate estimate) {
    _kcalController.text = _format(estimate.kcal);
    _proteinaController.text = _format(estimate.proteina);
    _carbosController.text = _format(estimate.carbos);
    _grasaController.text = _format(estimate.grasa);
  }

  /// Formatea un número sin decimales superfluos (12.0 → "12", 12.5 → "12.5").
  String _format(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  /// Parsea el texto de un campo a double, tolerando coma decimal. Null si vacío
  /// o no numérico.
  double? _parse(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _onEstimate() {
    final descripcion = _descripcionController.text.trim();
    if (descripcion.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(mealEntryControllerProvider.notifier).estimate(descripcion);
  }

  void _onSave() {
    final kcal = _parse(_kcalController);
    final proteina = _parse(_proteinaController);
    final carbos = _parse(_carbosController);
    final grasa = _parse(_grasaController);

    if (kcal == null || proteina == null || carbos == null || grasa == null) {
      _showSnackBar('Introduce valores numéricos válidos en todos los campos.');
      return;
    }

    FocusScope.of(context).unfocus();
    ref.read(mealEntryControllerProvider.notifier).save(
          descripcion: _descripcionController.text,
          kcal: kcal,
          proteina: proteina,
          carbos: carbos,
          grasa: grasa,
        );
  }

  /// Descarta la comida sin guardar: resetea el estado y cierra el sheet. No
  /// toca la BD ni dispara ninguna recarga de la pantalla del día.
  void _onCancel() {
    ref.read(mealEntryControllerProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Reacciona a las transiciones del flujo: prerrellenar al estimar; al guardar
    // con éxito, refrescar la pantalla del día y cerrar; y mostrar errores.
    ref.listen<MealEntryState>(mealEntryControllerProvider, (previous, next) {
      if (next.estimate != null && next.estimate != previous?.estimate) {
        _fillMacroFields(next.estimate!);
      }
      if (next.status == MealEntryStatus.saved &&
          previous?.status != MealEntryStatus.saved) {
        // Reactividad: invalidar la lectura de hoy fuerza el refetch y la
        // pantalla principal (barra + macros + lista) se recompone sola.
        ref.invalidate(todayFoodLogsProvider);
        ref.read(mealEntryControllerProvider.notifier).reset();
        Navigator.of(context).pop();
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showSnackBar(next.errorMessage!);
      }
    });

    final state = ref.watch(mealEntryControllerProvider);
    final media = MediaQuery.of(context);

    // Compacto al describir; casi pantalla completa tras estimar.
    final expanded = state.hasEstimate;
    // Alto disponible descontando los insets del diálogo y el teclado.
    final maxHeight =
        media.size.height - AppSpacing.l * 2 - media.viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        // Respeta el teclado: empuja el contenido por encima del IME.
        bottom: AppSpacing.l + media.viewInsets.bottom,
      ),
      // Anima la transición compacto → casi-fullscreen al estimar.
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            // Al expandir, fuerza el alto para ocupar casi toda la pantalla.
            minHeight: expanded ? maxHeight : 0,
          ),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DialogHeader(onClose: _onCancel),
                  const SizedBox(height: AppSpacing.l),
                  _DescriptionSection(
                    controller: _descripcionController,
                    isEstimating: state.isEstimating,
                    onEstimate: _onEstimate,
                  ),
                  if (state.hasEstimate) ...[
                    const SizedBox(height: AppSpacing.l),
                    _EstimateForm(
                      kcalController: _kcalController,
                      proteinaController: _proteinaController,
                      carbosController: _carbosController,
                      grasaController: _grasaController,
                      isSaving: state.isSaving,
                      onSave: _onSave,
                      onCancel: _onCancel,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera del diálogo: título y botón de cierre (descarta sin guardar).
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Añadir comida', style: textTheme.labelLarge),
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: context.palette.textSecondary),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }
}

/// Bloque de descripción + botón "Estimar".
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.controller,
    required this.isEstimating,
    required this.onEstimate,
  });

  final TextEditingController controller;
  final bool isEstimating;
  final VoidCallback onEstimate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('DESCRIBE TU COMIDA', style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        AppTextField(
          controller: controller,
          label: 'Ej. 100g de arroz con pollo y ensalada',
        ),
        const SizedBox(height: AppSpacing.m),
        // El botón reacciona al texto para deshabilitarse si está vacío.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return AppButton(
              label: 'Estimar',
              variant: AppButtonVariant.nutrition,
              isLoading: isEstimating,
              onPressed: hasText ? onEstimate : null,
            );
          },
        ),
      ],
    );
  }
}

/// Formulario editable con la estimación de la IA + botones "Guardar" y
/// "Cancelar".
class _EstimateForm extends StatelessWidget {
  const _EstimateForm({
    required this.kcalController,
    required this.proteinaController,
    required this.carbosController,
    required this.grasaController,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController kcalController;
  final TextEditingController proteinaController;
  final TextEditingController carbosController;
  final TextEditingController grasaController;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Revisa y ajusta',
            style: textTheme.labelLarge?.copyWith(
              color: context.palette.accentNutrition,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Valores estimados por la IA. Edítalos si hace falta antes de guardar.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.l),
          MacroField(
            label: 'Calorías',
            unit: 'kcal',
            controller: kcalController,
          ),
          const SizedBox(height: AppSpacing.m),
          MacroField(
            label: 'Proteína',
            unit: 'g',
            controller: proteinaController,
          ),
          const SizedBox(height: AppSpacing.m),
          MacroField(label: 'Carbos', unit: 'g', controller: carbosController),
          const SizedBox(height: AppSpacing.m),
          MacroField(label: 'Grasa', unit: 'g', controller: grasaController),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: 'Guardar',
            variant: AppButtonVariant.nutrition,
            isLoading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.neutral,
            // Se deshabilita mientras se guarda para no descartar a medias.
            onPressed: isSaving ? null : onCancel,
          ),
        ],
      ),
    );
  }
}
