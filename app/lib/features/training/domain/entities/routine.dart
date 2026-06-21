import 'routine_exercise_item.dart';

/// Una rutina (plantilla) de entreno, estilo Hevy: una lista ordenada de
/// ejercicios del catálogo con sus series objetivo y un día de la semana opcional.
///
/// Es una fila de `routines` más sus `routine_exercises` ([items]). Para el
/// LISTADO basta la cabecera ([id], [nombre]) y, opcionalmente, los items para
/// mostrar un resumen; para EDITAR o EMPEZAR se cargan los [items] completos
/// (ordenados por `orden`). Entidad pura de dominio. Inmutable.
class Routine {
  const Routine({
    required this.id,
    required this.nombre,
    this.items = const [],
  });

  final int id;

  final String nombre;

  /// Ejercicios de la rutina, ordenados por `orden`. Puede venir vacío en el
  /// listado si solo se cargó la cabecera.
  final List<RoutineExerciseItem> items;

  /// Día de la semana de la rutina (la UI maneja un único día por rutina, aplicado
  /// a todos sus items). Se toma del primer item; `null` si no hay items o sin día.
  int? get diaSemana => items.isEmpty ? null : items.first.diaSemana;

  Routine copyWith({
    int? id,
    String? nombre,
    List<RoutineExerciseItem>? items,
  }) {
    return Routine(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      items: items ?? this.items,
    );
  }
}
