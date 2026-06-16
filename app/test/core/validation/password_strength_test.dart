import 'package:app/core/validation/password_strength.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluatePasswordStrength', () {
    test('vacía es débil con score 0', () {
      final result = evaluatePasswordStrength('');
      expect(result.level, PasswordStrength.weak);
      expect(result.score, 0.0);
      expect(result.label, 'Débil');
    });

    test('una contraseña simple corta es débil', () {
      expect(evaluatePasswordStrength('abc').level, PasswordStrength.weak);
    });

    test('longitud mínima con letra y número es media', () {
      expect(evaluatePasswordStrength('abc12345').level, PasswordStrength.medium);
    });

    test('larga con mayús, minús, número y símbolo es fuerte', () {
      final result = evaluatePasswordStrength('Abc12345!');
      expect(result.level, PasswordStrength.strong);
      expect(result.score, greaterThanOrEqualTo(0.8));
    });

    test('el score siempre está entre 0 y 1', () {
      for (final pwd in ['', 'a', 'abc12345', 'Abcdef123!@#']) {
        final score = evaluatePasswordStrength(pwd).score;
        expect(score, inInclusiveRange(0.0, 1.0));
      }
    });
  });
}
