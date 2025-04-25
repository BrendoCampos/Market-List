import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_model.dart';

final calculatorProvider =
    StateNotifierProvider<CalculatorController, List<CalculatorItem>>(
  (ref) => CalculatorController(),
);

class CalculatorController extends StateNotifier<List<CalculatorItem>> {
  CalculatorController() : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('calculator_items');
    if (raw != null) {
      final decoded = json.decode(raw) as List;
      state = decoded.map((e) => CalculatorItem.fromJson(e)).toList();
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'calculator_items', json.encode(state.map((e) => e.toJson()).toList()));
  }

  void addItem(CalculatorItem item) {
    state = [...state, item];
    _saveItems();
  }

  void removeItem(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
    _saveItems();
  }

  void clearAll() {
    state = [];
    _saveItems();
  }

  void editItem(int index, CalculatorItem newItem) {
    final updated = [...state];
    updated[index] = newItem;
    state = updated;
    _saveItems();
  }

  double get total => state.fold(0.0, (sum, item) => sum + item.total);
}
