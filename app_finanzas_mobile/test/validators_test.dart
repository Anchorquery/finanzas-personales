import 'package:app_finanzas_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.isValidEmail', () {
    test('accepts simple email', () {
      expect(Validators.isValidEmail('user@example.com'), isTrue);
    });
    test('accepts email with subdomain + plus', () {
      expect(
          Validators.isValidEmail('user+tag@mail.example.co'), isTrue);
    });
    test('rejects no @', () {
      expect(Validators.isValidEmail('userexample.com'), isFalse);
    });
    test('rejects no TLD', () {
      expect(Validators.isValidEmail('user@example'), isFalse);
    });
    test('rejects spaces', () {
      expect(Validators.isValidEmail('user @example.com'), isFalse);
    });
    test('trims before matching', () {
      expect(Validators.isValidEmail('  user@example.com  '), isTrue);
    });
    test('rejects empty', () {
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  group('Validators.email (Form validator)', () {
    test('null returns "requerido"', () {
      expect(Validators.email(null), contains('requerido'));
    });
    test('empty returns "requerido"', () {
      expect(Validators.email(''), contains('requerido'));
    });
    test('invalid returns "inválido"', () {
      expect(Validators.email('not-email'), contains('inválido'));
    });
    test('valid returns null', () {
      expect(Validators.email('a@b.co'), isNull);
    });
  });

  group('Validators.requiredText', () {
    test('empty returns error', () {
      expect(Validators.requiredText(''), isNotNull);
    });
    test('whitespace returns error', () {
      expect(Validators.requiredText('   '), isNotNull);
    });
    test('non-empty returns null', () {
      expect(Validators.requiredText('hello'), isNull);
    });
    test('label appears in error', () {
      expect(Validators.requiredText(null, label: 'Nombre'),
          contains('Nombre'));
    });
  });

  group('Validators.positiveAmount', () {
    test('empty rejected', () {
      expect(Validators.positiveAmount(''), isNotNull);
    });
    test('non-numeric rejected', () {
      expect(Validators.positiveAmount('abc'), contains('inválido'));
    });
    test('zero rejected', () {
      expect(Validators.positiveAmount('0'), contains('mayor que cero'));
    });
    test('negative rejected', () {
      expect(Validators.positiveAmount('-5'), contains('mayor que cero'));
    });
    test('positive accepted', () {
      expect(Validators.positiveAmount('10.5'), isNull);
    });
    test('comma decimal accepted', () {
      expect(Validators.positiveAmount('10,5'), isNull);
    });
  });

  group('Validators.minLengthText', () {
    test('shorter rejected', () {
      expect(Validators.minLengthText('ab', 3), isNotNull);
    });
    test('exact length accepted', () {
      expect(Validators.minLengthText('abc', 3), isNull);
    });
    test('longer accepted', () {
      expect(Validators.minLengthText('abcde', 3), isNull);
    });
    test('null counted as length 0', () {
      expect(Validators.minLengthText(null, 1), isNotNull);
    });
  });
}
