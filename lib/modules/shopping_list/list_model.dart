import 'package:uuid/uuid.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool checked;

  ShoppingItem({
    String? id,
    required this.name,
    this.checked = false,
  }) : id = id ?? const Uuid().v4();

  ShoppingItem copyWith({String? name, bool? checked}) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      checked: json['checked'] ?? false,
    );
  }
}

class ShoppingList {
  final String id;
  final String title;
  final List<ShoppingItem> items;

  ShoppingList({
    String? id,
    required this.title,
    required this.items,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items.map((item) => item.toJson()).toList(),
      };

  ShoppingList copyWith({String? title, List<ShoppingItem>? items}) {
    return ShoppingList(
      id: id,
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      title: json['title'],
      items: (json['items'] as List)
          .map((item) => ShoppingItem.fromJson(item))
          .toList(),
    );
  }
}
