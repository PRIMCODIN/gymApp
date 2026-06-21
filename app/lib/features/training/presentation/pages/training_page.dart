import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/exercise.dart';
import '../utils/muscle_groups.dart';
import '../widgets/exercise_picker_sheet.dart';

/// Pantalla de Entreno — versión MÍNIMA de verificación de la fundación.
///
/// Por ahora solo abre el selector de ejercicio reutilizable y muestra el
/// ejercicio elegido. NO es la pantalla final de Entreno (la sesión activa y las
/// rutinas llegan en fases siguientes); sirve para comprobar que el catálogo se
/// lee de Supabase y que el selector funciona end-to-end.
class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  /// Ejercicio elegido en el selector (estado de UI efímero de prueba).
  Exercise? _selected;

  Future<void> _openPicker() async {
    final exercise = await showExercisePicker(context);
    if (exercise == null || !mounted) return;
    setState(() => _selected = exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entreno')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Elegir ejercicio',
                onPressed: _openPicker,
              ),
              const SizedBox(height: AppSpacing.l),
              if (_selected != null) _SelectedExerciseCard(exercise: _selected!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de prueba con el ejercicio seleccionado.
class _SelectedExerciseCard extends StatelessWidget {
  const _SelectedExerciseCard({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EJERCICIO SELECCIONADO', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.s),
          Text(exercise.nombre, style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            muscleGroupLabel(exercise.grupoMuscular),
            style: textTheme.bodySmall,
          ),
          if (exercise.isCustom) ...[
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: palette.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: AppSpacing.m,
                    color: palette.accentTraining,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Personalizado',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.accentTraining,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
