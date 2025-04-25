import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_model.dart';

final shoppingListProvider =
    StateNotifierProvider<ShoppingListController, List<ShoppingList>>(
  (ref) => ShoppingListController(),
);

class ShoppingListController extends StateNotifier<List<ShoppingList>> {
  ShoppingListController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shopping_lists');
    if (raw != null) {
      final decoded = json.decode(raw) as List;
      state = decoded.map((e) => ShoppingList.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'shopping_lists', json.encode(state.map((e) => e.toJson()).toList()));
  }

  void addList(String title) {
    if (title.trim().isEmpty) return;
    state = [...state, ShoppingList(title: title, items: [])];
    _save();
  }

  void removeList(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
    _save();
  }

  void editListTitle(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final updated = [...state];
    updated[index] = ShoppingList(title: newTitle, items: updated[index].items);
    state = updated;
    _save();
  }

  void addItem(int listIndex, String itemName) {
    final newList = [...state];
    newList[listIndex].items.add(ShoppingItem(name: itemName));
    state = newList;
    _save();
  }

  void removeItem(int listIndex, int itemIndex) {
    final newList = [...state];
    newList[listIndex].items.removeAt(itemIndex);
    state = newList;
    _save();
  }

  void toggleItem(int listIndex, int itemIndex) {
    final list = [...state];
    final item = list[listIndex].items[itemIndex];
    list[listIndex].items[itemIndex] = item.copyWith(checked: !item.checked);
    state = list;
    _save();
  }

  void editItemName(int listIndex, int itemIndex, String newName) {
    if (newName.trim().isEmpty) return;
    final list = [...state];
    final item = list[listIndex].items[itemIndex];
    list[listIndex].items[itemIndex] =
        item.copyWith(name: newName); // preserve checked!
    state = list;
    _save();
  }
}
