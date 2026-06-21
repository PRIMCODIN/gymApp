import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/exercise.dart';
import '../state/exercise_catalog_providers.dart';
import '../utils/muscle_groups.dart';
import 'create_custom_exercise_form.dart';

/// Abre el selector de ejercicio en un bottom sheet casi a pantalla completa y
/// devuelve el [Exercise] elegido (o null si se cierra sin elegir).
///
/// Selector reutilizable y DESACOPLADO: solo devuelve el ejercicio vía
/// `Navigator.pop`; no lo cablea a ninguna pantalla. Pensado para reutilizarse
/// desde rutinas y sesión en fases siguientes.
Future<Exercise?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.card),
      ),
    ),
    builder: (_) => const ExercisePickerSheet(),
  );
}

/// Contenido del selector: buscador por nombre + chips de filtro por grupo
/// muscular + lista del catálogo. El catálogo se carga una vez
/// ([exerciseCatalogProvider]) y el filtrado (nombre + grupo) es en cliente.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({super.key});

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  final _searchController = TextEditingController();

  /// Texto de búsqueda (estado de UI efímero, no de negocio).
  String _query = '';

  /// Grupo muscular filtrado (null = "Todos").
  String? _groupFilter;

  @override
  void initState() {
    super.initState();
    // Filtrado en vivo: el buscador filtra sobre la lista ya cargada.
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    if (_query == _searchController.text) return;
    setState(() => _query = _searchController.text);
  }

  /// Aplica búsqueda por nombre (case-insensitive) y filtro de grupo sobre el
  /// catálogo ya cargado.
  List<Exercise> _applyFilters(List<Exercise> catalog) {
    final query = _query.trim().toLowerCase();
    return catalog.where((exercise) {
      final matchesGroup =
          _groupFilter == null || exercise.grupoMuscular == _groupFilter;
      final matchesQuery =
          query.isEmpty || exercise.nombre.toLowerCase().contains(query);
      return matchesGroup && matchesQuery;
    }).toList();
  }

  Future<void> _onCreateCustom() async {
    // Prerrellena el nombre con lo que el usuario buscó y no encontró.
    final created = await showCreateCustomExerciseForm(
      context,
      initialName: _searchController.text.trim(),
    );
    if (created == null || !mounted) return;
    // Devuelve el ejercicio recién creado como selección del picker.
    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(exerciseCatalogProvider);
    final media = MediaQuery.of(context);
    // Casi pantalla completa, respetando el teclado.
    final maxHeight = media.size.height * 0.9 - media.viewInsets.bottom;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.s,
                ),
                child: AppTextField(
                  controller: _searchController,
                  label: 'Buscar ejercicio',
                  prefixIcon: Icons.search,
                  textInputAction: TextInputAction.search,
                ),
              ),
              Expanded(
                child: catalogAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _ErrorState(
                    onRetry: () => ref.invalidate(exerciseCatalogProvider),
                  ),
                  data: (catalog) => _CatalogBody(
                    catalog: catalog,
                    groupFilter: _groupFilter,
                    onGroupSelected: (group) =>
                        setState(() => _groupFilter = group),
                    results: _applyFilters(catalog),
                    onPick: (exercise) =>
                        Navigator.of(context).pop(exercise),
                    onCreateCustom: _onCreateCustom,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera del sheet: título + botón de cierre.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Elegir ejercicio', style: textTheme.labelLarge),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: context.palette.textSecondary),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

/// Cuerpo con datos: chips de filtro + resultados (o estado vacío con opción de
/// crear un ejercicio personalizado).
class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.catalog,
    required this.groupFilter,
    required this.onGroupSelected,
    required this.results,
    required this.onPick,
    required this.onCreateCustom,
  });

  final List<Exercise> catalog;
  final String? groupFilter;
  final ValueChanged<String?> onGroupSelected;
  final List<Exercise> results;
  final ValueChanged<Exercise> onPick;
  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupFilterChips(
          selected: groupFilter,
          onSelected: onGroupSelected,
        ),
        const SizedBox(height: AppSpacing.s),
        Expanded(
          child: results.isEmpty
              ? _EmptyResults(onCreateCustom: onCreateCustom)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    AppSpacing.l,
                  ),
                  itemCount: results.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    // Última fila: acción de crear personalizado, siempre visible.
                    if (index == results.length) {
                      return _CreateCustomTile(onTap: onCreateCustom);
                    }
                    return _ExerciseTile(
                      exercise: results[index],
                      onTap: () => onPick(results[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Fila scrollable de chips: "Todos" + un grupo muscular activo.
class _GroupFilterChips extends StatelessWidget {
  const _GroupFilterChips({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              backgroundColor: palette.surfaceElevated,
              selectedColor: palette.accentTraining,
            ),
          ),
          for (final group in kMuscleGroups)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: ChoiceChip(
                label: Text(muscleGroupLabel(group)),
                selected: selected == group,
                onSelected: (_) => onSelected(group),
                backgroundColor: palette.surfaceElevated,
                selectedColor: palette.accentTraining,
              ),
            ),
        ],
      ),
    );
  }
}

/// Fila de un ejercicio del catálogo. Muestra el grupo muscular y una marca si es
/// personalizado.
class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Material(
      color: palette.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.nombre, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      muscleGroupLabel(exercise.grupoMuscular),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (exercise.isCustom)
                Icon(
                  Icons.person_outline,
                  size: AppSpacing.m,
                  color: palette.accentTraining,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila/acción para crear un ejercicio personalizado.
class _CreateCustomTile extends StatelessWidget {
  const _CreateCustomTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: palette.accentTraining, size: AppSpacing.l),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Crear ejercicio personalizado',
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.accentTraining,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado vacío: la búsqueda/filtro no devuelve resultados. Ofrece crear uno.
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onCreateCustom});

  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No hay ejercicios que coincidan.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          _CreateCustomTile(onTap: onCreateCustom),
        ],
      ),
    );
  }
}

/// Estado de error de la carga del catálogo, con reintento.
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
              'No se pudo cargar el catálogo de ejercicios.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
