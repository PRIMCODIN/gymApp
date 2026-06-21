import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/training_failure.dart';
import '../../domain/entities/routine.dart';
import '../state/active_workout_controller.dart';
import '../state/routine_providers.dart';
import '../utils/weekday_label.dart';
import 'routine_editor_page.dart';

/// Lista de rutinas (plantillas) del usuario. Cada tarjeta permite editar,
/// borrar y empezar una sesión precargada desde la rutina. El botón inferior crea
/// una rutina nueva. La lista se observa con `routinesListProvider` (AsyncValue:
/// loading/error/data) y se invalida tras crear/editar/borrar.
class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis rutinas')),
      body: SafeArea(
        child: routinesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorState(
            onRetry: () => ref.invalidate(routinesListProvider),
          ),
          data: (routines) => routines.isEmpty
              ? const _EmptyState()
              : _RoutinesList(routines: routines),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: context.palette.accentTraining,
        icon: const Icon(Icons.add),
        label: const Text('Nueva rutina'),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RoutineEditorPage()),
    );
  }
}

/// Lista scrollable de tarjetas de rutina.
class _RoutinesList extends StatelessWidget {
  const _RoutinesList({required this.routines});

  final List<Routine> routines;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        // Hueco para que el FAB no tape la última tarjeta.
        AppSpacing.xl * 2,
      ),
      itemCount: routines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) => _RoutineCard(routine: routines[index]),
    );
  }
}

/// Tarjeta de una rutina: nombre + resumen (nº ejercicios, día) + acciones.
class _RoutineCard extends ConsumerWidget {
  const _RoutineCard({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(routine.nombre, style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _resumen(routine),
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Empezar',
                  onPressed: () => _start(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                onPressed: () => _edit(context),
                tooltip: 'Editar rutina',
                icon: Icon(Icons.edit_outlined, color: palette.textSecondary),
              ),
              IconButton(
                onPressed: () => _delete(context, ref),
                tooltip: 'Borrar rutina',
                icon: Icon(Icons.delete_outline, color: palette.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Resumen legible: nº de ejercicios + día de la semana si aplica.
  String _resumen(Routine routine) {
    final n = routine.items.length;
    final ejercicios = n == 1 ? '1 ejercicio' : '$n ejercicios';
    final dia = routine.diaSemana;
    if (dia == null) return ejercicios;
    return '$ejercicios · ${weekdayLabel(dia)}';
  }

  /// Empieza la sesión precargada desde la rutina (la lista ya trae sus items) y
  /// vuelve a la pestaña Entreno, que mostrará la sesión activa.
  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(activeWorkoutControllerProvider.notifier);
    await notifier.startFromRoutine(routine);
    if (!context.mounted) return;
    // Si arrancó bien hay sesión activa: cerramos esta pantalla para verla.
    if (ref.read(activeWorkoutControllerProvider).workout != null) {
      Navigator.of(context).pop();
    }
    // Si falló, el error queda en el estado y lo muestra TrainingPage al volver.
  }

  Future<void> _edit(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutineEditorPage(routine: routine),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar rutina'),
        content: Text('¿Seguro que quieres borrar "${routine.nombre}"?'),
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
      await ref.read(deleteRoutineProvider).call(routine.id);
      ref.invalidate(routinesListProvider);
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Rutina borrada.')));
    } catch (error) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(mapTrainingError(error).message)));
    }
  }
}

/// Estado vacío: aún no hay rutinas.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Todavía no tienes rutinas',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Crea una plantilla con tus ejercicios y empieza tus sesiones desde '
            'ella con un toque.',
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Estado de error de la carga de rutinas, con reintento.
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
              'No se pudieron cargar tus rutinas.',
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
