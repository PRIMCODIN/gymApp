import 'package:app/core/validation/password_policy.dart';
import 'package:app/core/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('acepta un email con formato válido', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('  user.name+tag@sub.example.co  '), isNull);
    });

    test('rechaza vacío y formatos inválidos', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('sin-arroba'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a @b.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('acepta una contraseña que cumple la política', () {
      expect(Validators.password('abc12345'), isNull);
    });

    test('rechaza vacía, corta, sin letra o sin número', () {
      expect(Validators.password(''), PasswordPolicy.emptyMessage);
      expect(Validators.password('abc123'), PasswordPolicy.tooShortMessage);
      expect(Validators.password('12345678'), PasswordPolicy.missingLetterMessage);
      expect(Validators.password('abcdefgh'), PasswordPolicy.missingDigitMessage);
    });
  });

  group('Validators.confirmPassword', () {
    test('acepta cuando coincide', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    });

    test('rechaza vacío o cuando no coincide', () {
      expect(Validators.confirmPassword('', 'abc12345'), isNotNull);
      expect(Validators.confirmPassword('otra123', 'abc12345'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('acepta un nombre no vacío', () {
      expect(Validators.name('Víctor'), isNull);
    });

    test('rechaza vacío o solo espacios', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('   '), isNotNull);
      expect(Validators.name(null), isNotNull);
    });
  });
}
