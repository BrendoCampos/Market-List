import 'package:uuid/uuid.dart';

class CalculatorItem {
  final String id;
  final String description;
  final int quantity;
  final double price;

  CalculatorItem({
    String? id,
    required this.description,
    required this.quantity,
    required this.price,
  }) : id = id ?? const Uuid().v4();

  double get total => quantity * price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'quantity': quantity,
        'price': price,
      };

  factory CalculatorItem.fromJson(Map<String, dynamic> json) {
    return CalculatorItem(
      id: json['id'] as String?,
      description: json['description'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
