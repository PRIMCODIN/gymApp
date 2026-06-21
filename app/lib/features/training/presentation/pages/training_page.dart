import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/active_workout.dart';
import '../state/active_workout_controller.dart';
import '../utils/workout_session_format.dart';
import '../widgets/active_exercise_card.dart';
import '../widgets/empty_session_state.dart';
import '../widgets/exercise_picker_sheet.dart';
import 'routines_page.dart';
import 'workout_history_page.dart';

/// Pantalla de Entreno: sesión activa estilo Hevy.
///
/// Sin sesión iniciada muestra el arranque ("Empezar entreno"); con una sesión en
/// curso, la cabecera (nombre + cronómetro + finalizar/cancelar), las tarjetas de
/// cada ejercicio con sus sets y la columna PREVIOUS, y el botón de añadir
/// ejercicio. El estado vive en memoria ([ActiveWorkoutController]); el workout se
/// persiste al iniciar y los sets al finalizar.
class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutControllerProvider);

    // Nada de fallos silenciosos: cualquier error de BD se muestra y se limpia.
    ref.listen<ActiveWorkoutState>(activeWorkoutControllerProvider,
        (prev, next) {
      final message = next.errorMessage;
      if (message != null && message != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(activeWorkoutControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: state.workout == null
            ? _StartView(
                isLoading: state.isStarting,
                onStart: () =>
                    ref.read(activeWorkoutControllerProvider.notifier).start(),
              )
            : _ActiveSessionView(state: state),
      ),
    );
  }
}

/// Arranque: sin sesión activa. Un botón grande inicia el entreno libre.
class _StartView extends StatelessWidget {
  const _StartView({required this.isLoading, required this.onStart});

  final bool isLoading;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Entreno', style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Empieza una sesión libre y registra tus series sobre la marcha, '
            'o arranca desde una de tus rutinas.',
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: 'Empezar entreno',
            isLoading: isLoading,
            onPressed: onStart,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            label: 'Mis rutinas',
            variant: AppButtonVariant.neutral,
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RoutinesPage(),
                      ),
                    ),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            label: 'Historial',
            variant: AppButtonVariant.neutral,
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WorkoutHistoryPage(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

/// Sesión en curso: cabecera + lista de ejercicios + finalizar.
class _ActiveSessionView extends ConsumerWidget {
  const _ActiveSessionView({required this.state});

  final ActiveWorkoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = state.workout!;
    final busy = state.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionHeader(
          workout: workout,
          busy: busy,
          onCancel: () => _cancel(context, ref),
        ),
        Expanded(
          child: workout.exercises.isEmpty
              ? EmptySessionState(
                  onAddExercise: () => _addExercise(context, ref),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    AppSpacing.s,
                    AppSpacing.m,
                    AppSpacing.m,
                  ),
                  itemCount: workout.exercises.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    if (index == workout.exercises.length) {
                      return AppButton(
                        label: 'Añadir ejercicio',
                        variant: AppButtonVariant.neutral,
                        onPressed: () => _addExercise(context, ref),
                      );
                    }
                    return ActiveExerciseCard(
                      index: index,
                      exercise: workout.exercises[index],
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: AppButton(
            label: 'Finalizar entreno',
            isLoading: busy,
            onPressed: () => _finish(context, ref),
          ),
        ),
      ],
    );
  }

  /// Abre el selector reutilizable y añade el ejercicio elegido a la sesión.
  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    final exercise = await showExercisePicker(context);
    if (exercise == null) return;
    ref.read(activeWorkoutControllerProvider.notifier).addExercise(exercise);
  }

  /// Confirma, finaliza la sesión y avisa del guardado.
  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Finalizar entreno',
      body: '¿Guardar y finalizar la sesión?',
      action: 'Finalizar',
    );
    if (confirmed != true) return;

    await ref.read(activeWorkoutControllerProvider.notifier).finish();
    if (!context.mounted) return;
    // Si el estado quedó limpio, el guardado fue bien (los errores los muestra
    // el listener global).
    if (ref.read(activeWorkoutControllerProvider).workout == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Entreno guardado.')));
    }
  }

  /// Confirma y descarta la sesión iniciada.
  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Descartar entreno',
      body: 'Se perderá esta sesión. ¿Descartarla?',
      action: 'Descartar',
    );
    if (confirmed != true) return;

    await ref.read(activeWorkoutControllerProvider.notifier).cancel();
    if (!context.mounted) return;
    if (ref.read(activeWorkoutControllerProvider).workout == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Sesión descartada.')));
    }
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

/// Cabecera de la sesión: botón descartar + nombre editable + cronómetro en vivo.
class _SessionHeader extends ConsumerStatefulWidget {
  const _SessionHeader({
    required this.workout,
    required this.busy,
    required this.onCancel,
  });

  final ActiveWorkout workout;
  final bool busy;
  final VoidCallback onCancel;

  @override
  ConsumerState<_SessionHeader> createState() => _SessionHeaderState();
}

class _SessionHeaderState extends ConsumerState<_SessionHeader> {
  late final TextEditingController _nameController;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout.nombre);
    _nameController.addListener(_onNameChanged);
    _elapsed = DateTime.now().difference(widget.workout.startedAt);
    // Cronómetro en vivo: refresca el tiempo transcurrido cada segundo.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed = DateTime.now().difference(widget.workout.startedAt);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    ref
        .read(activeWorkoutControllerProvider.notifier)
        .rename(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.busy ? null : widget.onCancel,
            tooltip: 'Descartar entreno',
            icon: Icon(Icons.close, color: palette.textSecondary),
          ),
          Expanded(
            child: AppTextField(
              controller: _nameController,
              label: 'Nombre del entreno',
              enabled: !widget.busy,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(formatStopwatch(_elapsed), style: textTheme.headlineMedium),
        ],
      ),
    );
  }
}
