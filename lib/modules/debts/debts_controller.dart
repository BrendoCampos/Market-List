import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'debts_model.dart';

final debtsProvider = StateNotifierProvider<DebtsController, List<DebtSheet>>(
  (ref) => DebtsController(),
);

class DebtsController extends StateNotifier<List<DebtSheet>> {
  DebtsController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('debts_sheets');
    if (raw != null) {
      final decoded = json.decode(raw) as List;
      state = decoded.map((e) => DebtSheet.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'debts_sheets',
      json.encode(state.map((e) => e.toJson()).toList()),
    );
  }

  void addSheet(DebtSheet sheet) {
    state = [...state, sheet];
    _save();
  }

  void editSheet(DebtSheet updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
    _save();
  }

  void removeSheet(String id) {
    state = state.where((s) => s.id != id).toList();
    _save();
  }
}
