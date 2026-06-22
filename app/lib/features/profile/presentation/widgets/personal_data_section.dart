import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/profile.dart';
import '../utils/age.dart';
import '../utils/profile_options.dart';

/// Bloque "Tus datos": seis filas etiqueta→valor (Sexo, Edad, Altura, Peso,
/// Nivel actividad, Objetivo). La edad se calcula en render desde
/// `fecha_nacimiento` (no se almacena). Cualquier campo null se muestra como
/// placeholder tenue "Añadir".
class PersonalDataSection extends StatelessWidget {
  const PersonalDataSection({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final age = ageFromBirthDate(profile.birthDate);

    final rows = <_DataRow>[
      _DataRow('Sexo', profile.sex == null ? null : sexLabel(profile.sex!)),
      _DataRow('Edad', age == null ? null : '$age años'),
      _DataRow('Altura', profile.heightCm == null ? null : '${profile.heightCm} cm'),
      _DataRow('Peso', profile.weightKg == null ? null : '${_formatWeight(profile.weightKg!)} kg'),
      _DataRow(
        'Nivel actividad',
        profile.activityLevel == null
            ? null
            : activityLevelLabel(profile.activityLevel!),
      ),
      _DataRow('Objetivo', profile.goal == null ? null : goalLabel(profile.goal!)),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('TUS DATOS', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.s),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(color: palette.divider, height: AppSpacing.l),
            _DataRowTile(row: rows[i]),
          ],
        ],
      ),
    );
  }

  /// Peso sin decimales superfluos (72.0 → "72", 72.5 → "72.5").
  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }
}

/// Par etiqueta→valor; [value] null significa "sin rellenar".
class _DataRow {
  const _DataRow(this.label, this.value);

  final String label;
  final String? value;
}

/// Fila visual: etiqueta a la izquierda, valor (o placeholder "Añadir") a la
/// derecha.
class _DataRowTile extends StatelessWidget {
  const _DataRowTile({required this.row});

  final _DataRow row;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = row.value != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          row.label,
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        Text(
          hasValue ? row.value! : 'Añadir',
          style: textTheme.bodyMedium?.copyWith(
            color: hasValue
                ? Theme.of(context).colorScheme.onSurface
                : palette.textTertiary,
          ),
        ),
      ],
    );
  }
}
