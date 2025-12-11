import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/modules/calculator/calculator_model.dart';

void main() {
  group('CalculatorItem', () {
    test('should calculate total correctly', () {
      final item = CalculatorItem(
        description: 'Arroz',
        quantity: 3,
        price: 5.50,
      );

      expect(item.total, equals(16.50));
    });

    test('should create item with generated id', () {
      final item = CalculatorItem(
        description: 'Feijão',
        quantity: 2,
        price: 8.00,
      );

      expect(item.id, isNotEmpty);
    });

    test('toJson and fromJson should work correctly', () {
      final item = CalculatorItem(
        id: 'test-id',
        description: 'Macarrão',
        quantity: 5,
        price: 3.50,
      );

      final json = item.toJson();
      final restored = CalculatorItem.fromJson(json);

      expect(restored.id, equals(item.id));
      expect(restored.description, equals(item.description));
      expect(restored.quantity, equals(item.quantity));
      expect(restored.price, equals(item.price));
      expect(restored.total, equals(item.total));
    });
  });
}
