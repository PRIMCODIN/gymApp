import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/training_failure.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_exercise_item.dart';
import '../state/routine_providers.dart';
import '../utils/muscle_groups.dart';
import '../utils/routine_session_builder.dart';
import '../utils/weekday_label.dart';
import '../widgets/exercise_picker_sheet.dart';

/// Series objetivo por defecto al añadir un ejercicio a una rutina.
const int _kDefaultSeries = 3;

/// Editor de una rutina: crear ([routine] == null) y editar comparten esta UI.
///
/// El borrador (nombre, día, lista de ejercicios) es estado de formulario EFÍMERO:
/// vive en el `State` con `setState` hasta que se guarda (mismo criterio que
/// `CreateCustomExerciseForm`); el estado de negocio sigue en Riverpod. Al guardar
/// llama a create/update, invalida la lista y vuelve atrás.
class RoutineEditorPage extends ConsumerStatefulWidget {
  const RoutineEditorPage({super.key, this.routine});

  /// Rutina a editar (con sus items ya cargados). `null` = crear una nueva.
  final Routine? routine;

  @override
  ConsumerState<RoutineEditorPage> createState() => _RoutineEditorPageState();
}

class _RoutineEditorPageState extends ConsumerState<RoutineEditorPage> {
  late final TextEditingController _nombreController;

  /// Día de la semana de la rutina (se aplica a todos sus items al guardar).
  int? _diaSemana;

  /// Borrador de ejercicios de la rutina, en orden.
  late List<RoutineExerciseItem> _items;

  bool _isSaving = false;

  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _nombreController = TextEditingController(text: routine?.nombre ?? '');
    _diaSemana = routine?.diaSemana;
    _items = [...?routine?.items];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercise = await showExercisePicker(context);
    if (exercise == null || !mounted) return;
    setState(() {
      _items = [
        ..._items,
        RoutineExerciseItem(
          exerciseId: exercise.id,
          nombreEjercicio: exercise.nombre,
          grupoMuscular: exercise.grupoMuscular,
          orden: _items.length + 1,
          seriesObjetivo: _kDefaultSeries,
          diaSemana: _diaSemana,
        ),
      ];
    });
  }

  void _setSeries(int index, int series) {
    if (series < 1) return;
    setState(() {
      final items = [..._items];
      items[index] = items[index].copyWith(seriesObjetivo: series);
      _items = items;
    });
  }

  void _move(int index, int direction) {
    setState(() => _items = reorderRoutineItems(_items, index, direction));
  }

  void _remove(int index) {
    setState(() {
      final items = [..._items]..removeAt(index);
      _items = [
        for (var i = 0; i < items.length; i++) items[i].copyWith(orden: i + 1),
      ];
    });
  }

  Future<void> _save() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _showSnackBar('Escribe un nombre para la rutina.');
      return;
    }
    if (_items.isEmpty) {
      _showSnackBar('Añade al menos un ejercicio.');
      return;
    }

    // Aplica el día de la rutina a todos los items y renumera el orden.
    final itemsToSave = [
      for (var i = 0; i < _items.length; i++)
        RoutineExerciseItem(
          exerciseId: _items[i].exerciseId,
          nombreEjercicio: _items[i].nombreEjercicio,
          grupoMuscular: _items[i].grupoMuscular,
          orden: i + 1,
          seriesObjetivo: _items[i].seriesObjetivo,
          diaSemana: _diaSemana,
        ),
    ];

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final routine = widget.routine;
      if (routine == null) {
        await ref.read(createRoutineProvider).call(nombre, itemsToSave);
      } else {
        await ref
            .read(updateRoutineProvider)
            .call(routine.id, nombre, itemsToSave);
        ref.invalidate(routineDetailProvider(routine.id));
      }
      ref.invalidate(routinesListProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on TrainingFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(failure.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('No se pudo guardar la rutina. Inténtalo de nuevo.');
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar rutina' : 'Nueva rutina'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.m),
                children: [
                  Text('NOMBRE', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  AppTextField(
                    controller: _nombreController,
                    label: 'Ej. Empuje, Pierna, Full body...',
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('DÍA DE LA SEMANA', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  _WeekdaySelector(
                    selected: _diaSemana,
                    enabled: !_isSaving,
                    onSelected: (dia) => setState(() => _diaSemana = dia),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text('EJERCICIOS', style: textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.s),
                  if (_items.isEmpty)
                    _EmptyItems()
                  else
                    for (var i = 0; i < _items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: _ItemCard(
                          item: _items[i],
                          isFirst: i == 0,
                          isLast: i == _items.length - 1,
                          enabled: !_isSaving,
                          onSeriesChanged: (series) => _setSeries(i, series),
                          onMoveUp: () => _move(i, -1),
                          onMoveDown: () => _move(i, 1),
                          onRemove: () => _remove(i),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.s),
                  AppButton(
                    label: 'Añadir ejercicio',
                    variant: AppButtonVariant.neutral,
                    onPressed: _isSaving ? null : _addExercise,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: AppButton(
                label: 'Guardar rutina',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector de día: "Sin día" + Lunes..Domingo. Solo uno activo.
class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final int? selected;
  final bool enabled;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        ChoiceChip(
          label: Text(weekdayLabel(null)),
          selected: selected == null,
          onSelected: enabled ? (_) => onSelected(null) : null,
          backgroundColor: palette.surfaceElevated,
          selectedColor: palette.accentTraining,
        ),
        for (final dia in kWeekdays)
          ChoiceChip(
            label: Text(weekdayLabel(dia)),
            selected: selected == dia,
            onSelected: enabled ? (_) => onSelected(dia) : null,
            backgroundColor: palette.surfaceElevated,
            selectedColor: palette.accentTraining,
          ),
      ],
    );
  }
}

/// Tarjeta de un ejercicio del borrador: nombre + grupo + stepper de series +
/// reordenar (↑/↓) + quitar.
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.onSeriesChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  final RoutineExerciseItem item;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final ValueChanged<int> onSeriesChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    // El grupo solo se muestra si se pudo resolver (ejercicio aún en catálogo).
    final grupo = item.grupoMuscular.isEmpty
        ? null
        : muscleGroupLabel(item.grupoMuscular);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombreEjercicio, style: textTheme.bodyMedium),
                    if (grupo != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        grupo,
                        style: textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: enabled && !isFirst ? onMoveUp : null,
                tooltip: 'Subir',
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
              IconButton(
                onPressed: enabled && !isLast ? onMoveDown : null,
                tooltip: 'Bajar',
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              IconButton(
                onPressed: enabled ? onRemove : null,
                tooltip: 'Quitar',
                icon: Icon(Icons.close, color: palette.textSecondary),
              ),
            ],
          ),
          _SeriesStepper(
            series: item.seriesObjetivo,
            enabled: enabled,
            onChanged: onSeriesChanged,
          ),
        ],
      ),
    );
  }
}

/// Control − valor + para las series objetivo (mínimo 1).
class _SeriesStepper extends StatelessWidget {
  const _SeriesStepper({
    required this.series,
    required this.enabled,
    required this.onChanged,
  });

  final int series;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Row(
      children: [
        Text(
          'Series objetivo',
          style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const Spacer(),
        IconButton(
          onPressed: enabled && series > 1 ? () => onChanged(series - 1) : null,
          tooltip: 'Quitar serie',
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: AppSpacing.l,
          child: Text(
            '$series',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
        IconButton(
          onPressed: enabled ? () => onChanged(series + 1) : null,
          tooltip: 'Añadir serie',
          icon: Icon(Icons.add_circle_outline, color: palette.accentTraining),
        ),
      ],
    );
  }
}

/// Aviso cuando aún no se ha añadido ningún ejercicio al borrador.
class _EmptyItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Text(
      'Aún no has añadido ejercicios. Usa "Añadir ejercicio" para empezar.',
      style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
    );
  }
}
