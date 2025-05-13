import 'package:uuid/uuid.dart';

class DebtItem {
  final String id;
  final String title;
  final double value;
  final int day;

  DebtItem({
    String? id,
    required this.title,
    required this.value,
    required this.day,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'value': value,
        'day': day,
      };

  factory DebtItem.fromJson(Map<String, dynamic> json) {
    return DebtItem(
      id: json['id'],
      title: json['title'],
      value: (json['value'] as num).toDouble(),
      day: json['day'],
    );
  }
}

class DebtSheet {
  final String id;
  final String name;
  final double budget15;
  final double budget30;
  final List<DebtItem> debts;

  DebtSheet({
    String? id,
    required this.name,
    this.budget15 = 0,
    this.budget30 = 0,
    required this.debts,
  }) : id = id ?? const Uuid().v4();

  double get total => debts.fold(0.0, (sum, d) => sum + d.value);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget15': budget15,
        'budget30': budget30,
        'debts': debts.map((e) => e.toJson()).toList(),
      };

  factory DebtSheet.fromJson(Map<String, dynamic> json) {
    return DebtSheet(
      id: json['id'],
      name: json['name'],
      budget15: (json['budget15'] ?? 0).toDouble(),
      budget30: (json['budget30'] ?? 0).toDouble(),
      debts: (json['debts'] as List).map((d) => DebtItem.fromJson(d)).toList(),
    );
  }

  DebtSheet copyWith({
    String? name,
    double? budget15,
    double? budget30,
    List<DebtItem>? debts,
  }) {
    return DebtSheet(
      id: id,
      name: name ?? this.name,
      budget15: budget15 ?? this.budget15,
      budget30: budget30 ?? this.budget30,
      debts: debts ?? this.debts,
    );
  }
}
