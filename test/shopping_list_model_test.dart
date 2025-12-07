import 'package:flutter_test/flutter_test.dart';
import 'package:Totalize/modules/shopping_list/list_model.dart';

void main() {
  group('ShoppingItem', () {
    test('should create item with default values', () {
      final item = ShoppingItem(name: 'Leite');
      
      expect(item.name, equals('Leite'));
      expect(item.checked, isFalse);
      expect(item.id, isNotEmpty);
    });

    test('should create item with custom values', () {
      final item = ShoppingItem(name: 'Pão', checked: true, id: 'test-id');
      
      expect(item.name, equals('Pão'));
      expect(item.checked, isTrue);
      expect(item.id, equals('test-id'));
    });

    test('copyWith should preserve id', () {
      final item = ShoppingItem(name: 'Leite', id: 'test-id');
      final copied = item.copyWith(name: 'Café');
      
      expect(copied.id, equals('test-id'));
      expect(copied.name, equals('Café'));
      expect(copied.checked, isFalse);
    });

    test('toJson and fromJson should work correctly', () {
      final item = ShoppingItem(name: 'Leite', checked: true, id: 'test-id');
      final json = item.toJson();
      final restored = ShoppingItem.fromJson(json);
      
      expect(restored.id, equals(item.id));
      expect(restored.name, equals(item.name));
      expect(restored.checked, equals(item.checked));
    });
  });

  group('ShoppingList', () {
    test('should create list with items', () {
      final items = [
        ShoppingItem(name: 'Leite'),
        ShoppingItem(name: 'Pão'),
      ];
      final list = ShoppingList(title: 'Supermercado', items: items);
      
      expect(list.title, equals('Supermercado'));
      expect(list.items.length, equals(2));
      expect(list.id, isNotEmpty);
    });

    test('copyWith should work correctly', () {
      final list = ShoppingList(title: 'Lista 1', items: [], id: 'test-id');
      final copied = list.copyWith(title: 'Lista 2');
      
      expect(copied.id, equals('test-id'));
      expect(copied.title, equals('Lista 2'));
    });

    test('toJson and fromJson should work correctly', () {
      final items = [ShoppingItem(name: 'Leite')];
      final list = ShoppingList(title: 'Supermercado', items: items, id: 'test-id');
      final json = list.toJson();
      final restored = ShoppingList.fromJson(json);
      
      expect(restored.id, equals(list.id));
      expect(restored.title, equals(list.title));
      expect(restored.items.length, equals(1));
      expect(restored.items[0].name, equals('Leite'));
    });
  });
}
