import 'package:app/features/profile/domain/utils/workout_streak.dart';
import 'package:flutter_test/flutter_test.dart';

// Semanas ISO de referencia (todas lunes–domingo), ancladas a junio 2026:
//   2026-06-22 (lun) … 2026-06-28 (dom)  -> "semana en curso" en la mayoría
//   2026-06-15 (lun) … 2026-06-21 (dom)
//   2026-06-08 (lun) … 2026-06-14 (dom)
//   2026-06-01 (lun) … 2026-06-07 (dom)

void main() {
  group('currentStreak', () {
    test('lista vacía -> racha 0', () {
      final streak = currentStreak(const [], now: DateTime(2026, 6, 24));

      expect(streak, 0);
    });

    test('varias semanas consecutivas cumplidas (incluida la actual) suman', () {
      final dates = [
        // Semana en curso (22-28): 3 sesiones -> cumplida.
        DateTime(2026, 6, 22),
        DateTime(2026, 6, 23),
        DateTime(2026, 6, 24),
        // Semana 15-21: 3 sesiones.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 17),
        DateTime(2026, 6, 21),
        // Semana 08-14: 3 sesiones.
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 14),
        // Semana 01-07: solo 2 -> corta la racha.
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 4),
      ];

      final streak = currentStreak(dates, now: DateTime(2026, 6, 24, 9, 30));

      expect(streak, 3);
    });

    test('una semana intermedia con <3 rompe la racha', () {
      final dates = [
        // Semana en curso (22-28): 3 -> cumplida.
        DateTime(2026, 6, 22),
        DateTime(2026, 6, 23),
        DateTime(2026, 6, 24),
        // Semana 15-21: 3.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 16),
        DateTime(2026, 6, 17),
        // Semana 08-14: 2 -> hueco, se para aquí.
        DateTime(2026, 6, 9),
        DateTime(2026, 6, 11),
        // Semana 01-07: 3 (ya no se cuenta, la racha se cortó antes).
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 3),
        DateTime(2026, 6, 5),
      ];

      final streak = currentStreak(dates, now: DateTime(2026, 6, 24));

      expect(streak, 2);
    });

    test('semana en curso incompleta pero alcanzable no rompe (mide desde la '
        'anterior)', () {
      final dates = [
        // Semana en curso (22-28): solo 1 sesión, miércoles -> 1 + 5 días
        // restantes = alcanzable, no penaliza.
        DateTime(2026, 6, 22),
        // Semana 15-21: 3.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 18),
        DateTime(2026, 6, 21),
        // Semana 08-14: 3.
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 11),
        DateTime(2026, 6, 13),
      ];

      // Miércoles 24 (weekday 3): quedan 5 días incluido hoy.
      final streak = currentStreak(dates, now: DateTime(2026, 6, 24));

      expect(streak, 2);
    });

    test('semana en curso ya cumplida suma sobre la racha previa', () {
      final dates = [
        // Semana en curso (22-28): 3 -> cumplida, suma.
        DateTime(2026, 6, 22),
        DateTime(2026, 6, 23),
        DateTime(2026, 6, 24),
        // Semana 15-21: 3.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 16),
        DateTime(2026, 6, 19),
        // Semana 08-14: 2 -> corta.
        DateTime(2026, 6, 9),
        DateTime(2026, 6, 12),
      ];

      final streak = currentStreak(dates, now: DateTime(2026, 6, 24));

      expect(streak, 2);
    });

    test('lunes con 0 entrenos esta semana no rompe la racha previa', () {
      final dates = [
        // Semana en curso (22-28): 0 sesiones. Lunes -> 7 días por delante,
        // perfectamente alcanzable: no penaliza.
        // Semana 15-21: 3.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 16),
        DateTime(2026, 6, 17),
        // Semana 08-14: 3.
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 9),
        DateTime(2026, 6, 10),
        // Semana 01-07: 2 -> corta.
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 2),
      ];

      // Lunes 22 (weekday 1): semana recién empezada.
      final streak = currentStreak(dates, now: DateTime(2026, 6, 22, 8));

      expect(streak, 2);
    });

    test('cuenta sesiones, no días distintos: 3 sesiones el mismo día cumplen',
        () {
      final dates = [
        // Tres sesiones el mismo lunes de la semana en curso -> cumplida.
        DateTime(2026, 6, 22, 7),
        DateTime(2026, 6, 22, 13),
        DateTime(2026, 6, 22, 19),
      ];

      final streak = currentStreak(dates, now: DateTime(2026, 6, 24));

      expect(streak, 1);
    });

    test('semana en curso sin cumplir, aunque ya no sea alcanzable, no rompe la '
        'racha previa (domingo con <3)', () {
      final dates = [
        // Semana en curso (22-28): 1 sesión y ya es domingo. No cumple, pero la
        // semana en curso nunca baja la racha: es neutra y se mide desde la
        // anterior.
        DateTime(2026, 6, 27),
        // Semana 15-21: 3.
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 16),
        DateTime(2026, 6, 17),
        // Semana 08-14: 3.
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 9),
        DateTime(2026, 6, 10),
        // Semana 01-07: 2 -> corta.
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 2),
      ];

      // Domingo 28 (weekday 7): solo queda hoy, pero da igual.
      final streak = currentStreak(dates, now: DateTime(2026, 6, 28, 20));

      expect(streak, 2);
    });
  });
}
