import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/modules/calculator/calculator_model.dart';
import 'package:Totalize/modules/debts/debts_model.dart';

void main() {
  group('CalculatorItem total calculation', () {
    test('should calculate subtotal correctly', () {
      final item1 = CalculatorItem(description: 'Arroz', quantity: 2, price: 5.50);
      final item2 = CalculatorItem(description: 'Feijão', quantity: 1, price: 8.00);

      final total = item1.total + item2.total;

      expect(item1.total, equals(11.00));
      expect(item2.total, equals(8.00));
      expect(total, equals(19.00));
    });
  });

  group('DebtSheet calculations', () {
    test('should calculate total and remaining correctly', () {
      final debts = [
        DebtItem(title: 'Aluguel', value: 1500.00, day: 15),
        DebtItem(title: 'Luz', value: 250.00, day: 30),
      ];
      final sheet = DebtSheet(
        name: 'Janeiro 2024',
        budget15: 2000.00,
        budget30: 500.00,
        debts: debts,
      );

      final totalBudget = sheet.budget15 + sheet.budget30;
      final remaining = totalBudget - sheet.total;

      expect(sheet.total, equals(1750.00));
      expect(totalBudget, equals(2500.00));
      expect(remaining, equals(750.00));
    });

    test('should identify deficit correctly', () {
      final debts = [
        DebtItem(title: 'Aluguel', value: 2000.00, day: 15),
        DebtItem(title: 'Luz', value: 1000.00, day: 30),
      ];
      final sheet = DebtSheet(
        name: 'Janeiro 2024',
        budget15: 1500.00,
        budget30: 500.00,
        debts: debts,
      );

      final totalBudget = sheet.budget15 + sheet.budget30;
      final remaining = totalBudget - sheet.total;
      final isDeficit = remaining < 0;

      expect(sheet.total, equals(3000.00));
      expect(totalBudget, equals(2000.00));
      expect(remaining, equals(-1000.00));
      expect(isDeficit, isTrue);
    });
  });
}
