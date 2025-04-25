class CalculatorItem {
  final String description;
  final int quantity;
  final double price;

  CalculatorItem({
    required this.description,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'price': price,
      };

  factory CalculatorItem.fromJson(Map<String, dynamic> json) {
    return CalculatorItem(
      description: json['description'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
