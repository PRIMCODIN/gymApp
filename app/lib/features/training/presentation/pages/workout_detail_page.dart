import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../nutrition/presentation/utils/day_label.dart';
import '../../data/training_failure.dart';
import '../../data/workout_stats.dart';
import '../../domain/entities/workout_detail.dart';
import '../state/workout_edit_controller.dart';
import '../state/workout_history_providers.dart';
import '../utils/workout_history_format.dart';
import '../utils/workout_session_format.dart';
import '../widgets/workout_detail_exercise_card.dart';
import '../widgets/workout_edit_exercise_card.dart';

/// Detalle de un workout finalizado. En SOLO LECTURA (D1) muestra cabecera y la
/// lista de ejercicios con sus sets, y permite borrar el workout. En MODO EDICIÓN
/// (D2) se trabaja sobre una copia en memoria (`workoutEditControllerProvider`):
/// se editan kg/reps, se borran sets/ejercicios y se edita nombre/fecha; "Guardar"
/// persiste y "Descartar" tira la copia. Carga con `workoutDetailProvider`.
class WorkoutDetailPage extends ConsumerWidget {
  const WorkoutDetailPage({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutDetailProvider(workoutId));
    final editState = ref.watch(workoutEditControllerProvider);
    final isEditing = editState.workout?.id == workoutId;

    // Muestra los errores de guardado sin salir del modo edición.
    ref.listen(workoutEditControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(workoutEditControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del entreno'),
        actions: [
          if (!isEditing)
            detailAsync.maybeWhen(
              data: (detail) => TextButton(
                onPressed: () => ref
                    .read(workoutEditControllerProvider.notifier)
                    .enterEditMode(detail),
                child: const Text('Editar'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: SafeArea(
        child: isEditing
            ? _EditView(workout: editState.workout!, state: editState)
            : detailAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _ErrorState(
                  onRetry: () =>
                      ref.invalidate(workoutDetailProvider(workoutId)),
                ),
                data: (detail) => _DetailView(detail: detail),
              ),
      ),
    );
  }
}

/// Cuerpo del detalle en solo lectura: cabecera + ejercicios (scroll) + botón de
/// borrar fijo.
class _DetailView extends ConsumerWidget {
  const _DetailView({required this.detail});

  final WorkoutDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _DetailHeader(detail: detail),
              const SizedBox(height: AppSpacing.l),
              for (final exercise in detail.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: WorkoutDetailExerciseCard(exercise: exercise),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: AppButton(
            label: 'Borrar workout',
            variant: AppButtonVariant.neutral,
            onPressed: () => _delete(context, ref),
          ),
        ),
      ],
    );
  }

  /// Confirma y borra el workout; refresca el día y el mes y cierra el detalle.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar entreno'),
        content: Text('¿Seguro que quieres borrar "${detail.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(deleteWorkoutProvider).call(detail.id);
      // Refresca el calendario (marcadores) y la lista del día.
      ref.invalidate(workoutDatesForMonthProvider);
      ref.invalidate(workoutsForDayProvider);
      navigator.pop();
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Entreno borrado.')));
    } catch (error) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(mapTrainingError(error).message)));
    }
  }
}

/// Cabecera del detalle (solo lectura): nombre + fecha/duración + resumen.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail});

  final WorkoutDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    final fecha = formatDayLabel(detail.fecha, DateTime.now());
    final duracion = detail.duracionS;
    final subtitle = duracion == null
        ? fecha
        : '$fecha · ${formatStopwatch(Duration(seconds: duracion))}';
    final volumen = computeTotalVolume(
      detail.exercises.expand((exercise) => exercise.sets),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(detail.nombre, style: textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          formatSummaryLine(detail.numEjercicios, detail.numSets, volumen),
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// Cuerpo del detalle en MODO EDICIÓN: cabecera editable + tarjetas editables +
/// barra inferior con Guardar/Descartar.
class _EditView extends ConsumerWidget {
  const _EditView({required this.workout, required this.state});

  final WorkoutDetail workout;
  final WorkoutEditState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _EditHeader(workout: workout),
              const SizedBox(height: AppSpacing.l),
              for (var i = 0; i < workout.exercises.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: WorkoutEditExerciseCard(
                    exerciseIndex: i,
                    exercise: workout.exercises[i],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Descartar',
                  variant: AppButtonVariant.neutral,
                  onPressed: () => _discard(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: AppButton(
                  label: 'Guardar',
                  isLoading: state.isSaving,
                  onPressed: () =>
                      ref.read(workoutEditControllerProvider.notifier).save(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Descarta la edición; pide confirmación si hubo cambios.
  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(workoutEditControllerProvider.notifier);
    if (!state.dirty) {
      controller.discard();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
          '¿Seguro que quieres descartar los cambios sin guardar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.discard();
  }
}

/// Cabecera editable: nombre (campo) + fecha (date picker) + resumen en vivo.
class _EditHeader extends ConsumerWidget {
  const _EditHeader({required this.workout});

  final WorkoutDetail workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final controller = ref.read(workoutEditControllerProvider.notifier);

    final volumen = computeTotalVolume(
      workout.exercises.expand((exercise) => exercise.sets),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditNameField(
          initialName: workout.nombre,
          onChanged: controller.renameWorkout,
        ),
        const SizedBox(height: AppSpacing.m),
        InkWell(
          onTap: () => _pickDate(context, controller),
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: AppSpacing.m,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  formatDayLabel(workout.fecha, DateTime.now()),
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          formatSummaryLine(workout.numEjercicios, workout.numSets, volumen),
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WorkoutEditController controller,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: workout.fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) controller.changeDate(picked);
  }
}

/// Campo de nombre del workout: `StatefulWidget` con su controller sembrado una
/// vez para no perder el cursor mientras se escribe.
class _EditNameField extends StatefulWidget {
  const _EditNameField({required this.initialName, required this.onChanged});

  final String initialName;
  final ValueChanged<String> onChanged;

  @override
  State<_EditNameField> createState() => _EditNameFieldState();
}

class _EditNameFieldState extends State<_EditNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(controller: _controller, label: 'Nombre del entreno');
  }
}

/// Estado de error de la carga del detalle, con reintento.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo cargar el entreno.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
