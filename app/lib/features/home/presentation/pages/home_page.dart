import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/display_name.dart';
import '../../../../core/utils/spanish_dates.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../profile/presentation/state/profile_providers.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/training_card.dart';

/// Pantalla de Inicio: hub de la app (ver `specs/006_inicio.md`).
///
/// Paso 1 del build: cabecera (saludo + nombre + fecha) y huecos maquetados para
/// las tres secciones que llegan después (Nutrición, Entreno, acciones rápidas).
/// Sin datos async de tarjetas todavía. El saludo es la cabecera de la pantalla,
/// así que no hay AppBar.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _HomeHeader(),
              SizedBox(height: AppSpacing.l),
              NutritionCard(),
              SizedBox(height: AppSpacing.l),
              TrainingCard(),
              SizedBox(height: AppSpacing.l),
              _SectionPlaceholder(label: 'Acciones rápidas'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera de Inicio: saludo según la hora local + nombre del usuario y, debajo,
/// la fecha de hoy en español.
///
/// El nombre sale de la misma fuente que Perfil ([profileProvider]); el saludo y la
/// fecha son síncronos, así que se pintan siempre sin spinner global. Mientras el
/// perfil carga o si falla, el nombre cae a "Sin nombre" vía [resolveDisplayName].
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final name = ref.watch(profileProvider).asData?.value.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting(now)}, ${resolveDisplayName(name)}',
          style: textTheme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _spanishDateLabel(now),
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// Saludo según la hora local del dispositivo (fronteras de `specs/006_inicio.md`):
/// "Buenos días" (<12), "Buenas tardes" (12–19), "Buenas noches" (≥20).
String _greeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Buenos días';
  if (hour < 20) return 'Buenas tardes';
  return 'Buenas noches';
}

/// Fecha de hoy en español, p.ej. "lunes, 22 de junio". Nombres de día y mes desde
/// `core/utils/spanish_dates.dart` (sin `intl`).
String _spanishDateLabel(DateTime d) {
  return '${spanishWeekdayName(d.weekday)}, ${d.day} de ${spanishMonthName(d.month)}';
}

/// Hueco maquetado para una sección que llega en pasos posteriores. Solo reserva
/// sitio: tarjeta gris (sin acento) con una etiqueta tenue. Sin lógica ni datos.
class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: SizedBox(
        height: 96,
        child: Center(
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: palette.textTertiary),
          ),
        ),
      ),
    );
  }
}
