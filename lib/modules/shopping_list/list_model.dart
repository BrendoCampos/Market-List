class ShoppingItem {
  final String name;
  final bool checked;

  ShoppingItem({required this.name, this.checked = false});

  ShoppingItem copyWith({String? name, bool? checked}) {
    return ShoppingItem(
      name: name ?? this.name,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'checked': checked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      checked: json['checked'] ?? false,
    );
  }
}

class ShoppingList {
  final String title;
  final List<ShoppingItem> items;

  ShoppingList({required this.title, required this.items});

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': items.map((item) => item.toJson()).toList(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      title: json['title'],
      items: (json['items'] as List)
          .map((item) => ShoppingItem.fromJson(item))
          .toList(),
    );
  }
}
