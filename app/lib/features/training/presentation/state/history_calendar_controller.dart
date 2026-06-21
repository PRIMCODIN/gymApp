import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de UI del calendario del historial: el mes mostrado ([year]/[month]) y
/// el día seleccionado ([selectedDay], sin hora). Inmutable.
class HistoryCalendarState {
  const HistoryCalendarState({
    required this.year,
    required this.month,
    required this.selectedDay,
  });

  final int year;
  final int month;
  final DateTime selectedDay;

  HistoryCalendarState copyWith({
    int? year,
    int? month,
    DateTime? selectedDay,
  }) {
    return HistoryCalendarState(
      year: year ?? this.year,
      month: month ?? this.month,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

/// Controla la navegación de meses y la selección de día del calendario. Solo
/// estado de UI (sin BD); las cargas las hacen los `FutureProvider` que observan
/// este estado. Por defecto muestra el mes actual con hoy seleccionado.
class HistoryCalendarController extends Notifier<HistoryCalendarState> {
  @override
  HistoryCalendarState build() {
    final now = DateTime.now();
    return HistoryCalendarState(
      year: now.year,
      month: now.month,
      selectedDay: DateTime(now.year, now.month, now.day),
    );
  }

  /// Selecciona un día (normalizado a medianoche local).
  void selectDay(DateTime day) {
    state = state.copyWith(
      selectedDay: DateTime(day.year, day.month, day.day),
    );
  }

  /// Mes anterior.
  void prevMonth() {
    final prev = DateTime(state.year, state.month - 1, 1);
    state = state.copyWith(year: prev.year, month: prev.month);
  }

  /// Mes siguiente.
  void nextMonth() {
    final next = DateTime(state.year, state.month + 1, 1);
    state = state.copyWith(year: next.year, month: next.month);
  }
}

final historyCalendarControllerProvider =
    NotifierProvider<HistoryCalendarController, HistoryCalendarState>(
  HistoryCalendarController.new,
);
