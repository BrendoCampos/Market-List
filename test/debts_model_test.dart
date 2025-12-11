import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/modules/debts/debts_model.dart';

void main() {
  group('DebtItem', () {
    test('should create debt with generated id', () {
      final debt = DebtItem(
        title: 'Aluguel',
        value: 1500.00,
        day: 15,
      );

      expect(debt.id, isNotEmpty);
      expect(debt.title, equals('Aluguel'));
      expect(debt.value, equals(1500.00));
      expect(debt.day, equals(15));
    });

    test('toJson and fromJson should work correctly', () {
      final debt = DebtItem(
        id: 'test-id',
        title: 'Luz',
        value: 250.50,
        day: 30,
      );

      final json = debt.toJson();
      final restored = DebtItem.fromJson(json);

      expect(restored.id, equals(debt.id));
      expect(restored.title, equals(debt.title));
      expect(restored.value, equals(debt.value));
      expect(restored.day, equals(debt.day));
    });
  });

  group('DebtSheet', () {
    test('should calculate total correctly', () {
      final debts = [
        DebtItem(title: 'Aluguel', value: 1500.00, day: 15),
        DebtItem(title: 'Luz', value: 250.00, day: 30),
        DebtItem(title: 'Água', value: 100.00, day: 30),
      ];

      final sheet = DebtSheet(
        name: 'Janeiro 2024',
        budget15: 2000.00,
        budget30: 1000.00,
        debts: debts,
      );

      expect(sheet.total, equals(1850.00));
    });

    test('copyWith should preserve id', () {
      final sheet = DebtSheet(
        id: 'test-id',
        name: 'Folha 1',
        budget15: 1000.00,
        budget30: 500.00,
        debts: [],
      );

      final copied = sheet.copyWith(name: 'Folha 2', budget15: 1500.00);

      expect(copied.id, equals('test-id'));
      expect(copied.name, equals('Folha 2'));
      expect(copied.budget15, equals(1500.00));
      expect(copied.budget30, equals(500.00));
    });

    test('toJson and fromJson should work correctly', () {
      final debts = [
        DebtItem(title: 'Aluguel', value: 1500.00, day: 15),
      ];

      final sheet = DebtSheet(
        id: 'test-id',
        name: 'Janeiro',
        budget15: 2000.00,
        budget30: 1000.00,
        debts: debts,
      );

      final json = sheet.toJson();
      final restored = DebtSheet.fromJson(json);

      expect(restored.id, equals(sheet.id));
      expect(restored.name, equals(sheet.name));
      expect(restored.budget15, equals(sheet.budget15));
      expect(restored.budget30, equals(sheet.budget30));
      expect(restored.debts.length, equals(1));
      expect(restored.debts[0].title, equals('Aluguel'));
      expect(restored.total, equals(sheet.total));
    });
  });
}
