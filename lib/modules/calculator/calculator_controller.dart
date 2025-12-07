import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calculator_model.dart';
import '../../core/storage_repository.dart';

final calculatorProvider =
    StateNotifierProvider<CalculatorController, CalculatorState>(
  (ref) => CalculatorController(),
);

class CalculatorState {
  final List<CalculatorItem> items;
  final String? errorMessage;
  final bool isLoading;

  CalculatorState({
    required this.items,
    this.errorMessage,
    this.isLoading = false,
  });

  CalculatorState copyWith({
    List<CalculatorItem>? items,
    String? errorMessage,
    bool? isLoading,
  }) {
    return CalculatorState(
      items: items ?? this.items,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalculatorController extends StateNotifier<CalculatorState> {
  final StorageRepository _repository = StorageRepository();

  CalculatorController() : super(CalculatorState(items: [])) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.loadCalculatorItems();
    
    if (result.isSuccess) {
      final items = result.data!.map((e) => CalculatorItem.fromJson(e)).toList();
      state = CalculatorState(items: items, isLoading: false);
    } else {
      state = CalculatorState(items: [], errorMessage: result.error, isLoading: false);
    }
  }

  Future<void> _saveItems() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.saveCalculatorItems(
      state.items.map((e) => e.toJson()).toList(),
    );
    
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(errorMessage: result.error, isLoading: false);
    }
  }

  void addItem(CalculatorItem item) {
    state = state.copyWith(items: [...state.items, item]);
    _saveItems();
  }

  void removeItemById(String id) {
    final newList = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: newList);
    _saveItems();
  }

  void clearAll() {
    state = state.copyWith(items: []);
    _saveItems();
  }

  void editItem(String id, CalculatorItem newItem) {
    final updated =
        state.items.map((item) => item.id == id ? newItem : item).toList();
    state = state.copyWith(items: updated);
    _saveItems();
  }

  double get total => state.items.fold(0.0, (sum, item) => sum + item.total);

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
