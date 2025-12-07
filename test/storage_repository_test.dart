import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/core/storage_repository.dart';

void main() {
  group('Result', () {
    test('success should have data and no error', () {
      final result = Result.success('test data');
      
      expect(result.isSuccess, isTrue);
      expect(result.data, equals('test data'));
      expect(result.error, isNull);
    });

    test('error should have error message and no data', () {
      final result = Result<String>.error('test error');
      
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.error, equals('test error'));
    });
  });
}
