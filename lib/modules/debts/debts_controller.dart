import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'debts_model.dart';
import '../../core/storage_repository.dart';

final debtsProvider = StateNotifierProvider<DebtsController, DebtsState>(
  (ref) => DebtsController(),
);

class DebtsState {
  final List<DebtSheet> sheets;
  final String? errorMessage;
  final bool isLoading;
  final Map<String, Set<String>> paidDebtsBySheet;

  DebtsState({
    required this.sheets,
    this.errorMessage,
    this.isLoading = false,
    this.paidDebtsBySheet = const {},
  });

  DebtsState copyWith({
    List<DebtSheet>? sheets,
    String? errorMessage,
    bool? isLoading,
    Map<String, Set<String>>? paidDebtsBySheet,
  }) {
    return DebtsState(
      sheets: sheets ?? this.sheets,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      paidDebtsBySheet: paidDebtsBySheet ?? this.paidDebtsBySheet,
    );
  }
}

class DebtsController extends StateNotifier<DebtsState> {
  final StorageRepository _repository = StorageRepository();

  DebtsController() : super(DebtsState(sheets: [])) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.loadDebtsSheets();
    
    if (result.isSuccess) {
      final sheets = result.data!.map((e) => DebtSheet.fromJson(e)).toList();
      
      // Load paid debts for all sheets
      final Map<String, Set<String>> paidDebts = {};
      for (var sheet in sheets) {
        final paidResult = await _repository.loadPaidDebts(sheet.id);
        if (paidResult.isSuccess) {
          paidDebts[sheet.id] = paidResult.data!;
        }
      }
      
      state = DebtsState(
        sheets: sheets,
        isLoading: false,
        paidDebtsBySheet: paidDebts,
      );
    } else {
      state = DebtsState(sheets: [], errorMessage: result.error, isLoading: false);
    }
  }

  Future<void> _save() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.saveDebtsSheets(
      state.sheets.map((e) => e.toJson()).toList(),
    );
    
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(errorMessage: result.error, isLoading: false);
    }
  }

  void addSheet(DebtSheet sheet) {
    state = state.copyWith(sheets: [...state.sheets, sheet]);
    _save();
  }

  void editSheet(DebtSheet updated) {
    final updatedSheets = state.sheets.map((s) => s.id == updated.id ? updated : s).toList();
    state = state.copyWith(sheets: updatedSheets);
    _save();
  }

  void removeSheet(String id) {
    final updatedSheets = state.sheets.where((s) => s.id != id).toList();
    state = state.copyWith(sheets: updatedSheets);
    _save();
  }

  void togglePaidDebt(String sheetId, String debtId) {
    final currentPaid = state.paidDebtsBySheet[sheetId] ?? {};
    final newPaid = Set<String>.from(currentPaid);
    
    if (newPaid.contains(debtId)) {
      newPaid.remove(debtId);
    } else {
      newPaid.add(debtId);
    }
    
    final updatedMap = Map<String, Set<String>>.from(state.paidDebtsBySheet);
    updatedMap[sheetId] = newPaid;
    
    state = state.copyWith(paidDebtsBySheet: updatedMap);
    _repository.savePaidDebts(sheetId, newPaid);
  }

  bool isDebtPaid(String sheetId, String debtId) {
    return state.paidDebtsBySheet[sheetId]?.contains(debtId) ?? false;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
