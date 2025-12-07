import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/shared/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('should return error for null', () {
        expect(Validators.required(null), isNotNull);
      });

      test('should return error for empty string', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });

      test('should return null for valid string', () {
        expect(Validators.required('test'), isNull);
      });
    });

    group('positiveNumber', () {
      test('should return error for invalid number', () {
        expect(Validators.positiveNumber('abc'), isNotNull);
      });

      test('should return error for negative number', () {
        expect(Validators.positiveNumber('-5'), isNotNull);
      });

      test('should return null for positive number', () {
        expect(Validators.positiveNumber('10'), isNull);
        expect(Validators.positiveNumber('10.5'), isNull);
        expect(Validators.positiveNumber('10,5'), isNull);
      });

      test('should return null for zero', () {
        expect(Validators.positiveNumber('0'), isNull);
      });
    });

    group('positiveInteger', () {
      test('should return error for decimal', () {
        expect(Validators.positiveInteger('10.5'), isNotNull);
      });

      test('should return error for zero or negative', () {
        expect(Validators.positiveInteger('0'), isNotNull);
        expect(Validators.positiveInteger('-5'), isNotNull);
      });

      test('should return null for positive integer', () {
        expect(Validators.positiveInteger('10'), isNull);
      });
    });
  });
}
