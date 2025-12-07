import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'list_model.dart';
import '../../core/storage_repository.dart';

final shoppingListProvider =
    StateNotifierProvider<ShoppingListController, ShoppingListState>(
  (ref) => ShoppingListController(),
);

class ShoppingListState {
  final List<ShoppingList> lists;
  final String? errorMessage;
  final bool isLoading;

  ShoppingListState({
    required this.lists,
    this.errorMessage,
    this.isLoading = false,
  });

  ShoppingListState copyWith({
    List<ShoppingList>? lists,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ShoppingListState(
      lists: lists ?? this.lists,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ShoppingListController extends StateNotifier<ShoppingListState> {
  final StorageRepository _repository = StorageRepository();

  ShoppingListController() : super(ShoppingListState(lists: [])) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.loadShoppingLists();
    
    if (result.isSuccess) {
      final lists = result.data!.map((e) => ShoppingList.fromJson(e)).toList();
      state = ShoppingListState(lists: lists, isLoading: false);
    } else {
      state = ShoppingListState(lists: [], errorMessage: result.error, isLoading: false);
    }
  }

  Future<void> _save() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.saveShoppingLists(
      state.lists.map((e) => e.toJson()).toList(),
    );
    
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(errorMessage: result.error, isLoading: false);
    }
  }

  void addList(String title) {
    if (title.trim().isEmpty) return;
    final newLists = [...state.lists, ShoppingList(title: title, items: [])];
    state = state.copyWith(lists: newLists);
    _save();
  }

  void removeList(String listId) {
    final newLists = state.lists.where((list) => list.id != listId).toList();
    state = state.copyWith(lists: newLists);
    _save();
  }

  void editListTitle(String listId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final updated = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(title: newTitle);
      }
      return list;
    }).toList();
    state = state.copyWith(lists: updated);
    _save();
  }

  void addItem(String listId, String itemName) {
    if (itemName.trim().isEmpty) return;
    final updated = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          items: [...list.items, ShoppingItem(name: itemName)],
        );
      }
      return list;
    }).toList();
    state = state.copyWith(lists: updated);
    _save();
  }

  void removeItem(String listId, String itemId) {
    final updated = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          items: list.items.where((item) => item.id != itemId).toList(),
        );
      }
      return list;
    }).toList();
    state = state.copyWith(lists: updated);
    _save();
  }

  void toggleItem(String listId, String itemId) {
    final updated = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          items: list.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(checked: !item.checked);
            }
            return item;
          }).toList(),
        );
      }
      return list;
    }).toList();
    state = state.copyWith(lists: updated);
    _save();
  }

  void editItemName(String listId, String itemId, String newName) {
    if (newName.trim().isEmpty) return;
    final updated = state.lists.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          items: list.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(name: newName);
            }
            return item;
          }).toList(),
        );
      }
      return list;
    }).toList();
    state = state.copyWith(lists: updated);
    _save();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
