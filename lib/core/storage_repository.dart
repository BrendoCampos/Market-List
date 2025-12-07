import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  static const String _shoppingListsKey = 'shopping_lists';
  static const String _calculatorItemsKey = 'calculator_items';
  static const String _debtsSheetsKey = 'debts_sheets';
  static const String _themeKey = 'isDarkMode';

  // Shopping Lists
  Future<Result<List<Map<String, dynamic>>>> loadShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_shoppingListsKey);
      if (raw != null) {
        final decoded = json.decode(raw) as List;
        return Result.success(decoded.cast<Map<String, dynamic>>());
      }
      return Result.success([]);
    } catch (e) {
      return Result.error('Erro ao carregar listas: $e');
    }
  }

  Future<Result<void>> saveShoppingLists(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_shoppingListsKey, json.encode(data));
      return Result.success(null);
    } catch (e) {
      return Result.error('Erro ao salvar listas: $e');
    }
  }

  // Calculator Items
  Future<Result<List<Map<String, dynamic>>>> loadCalculatorItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_calculatorItemsKey);
      if (raw != null) {
        final decoded = json.decode(raw) as List;
        return Result.success(decoded.cast<Map<String, dynamic>>());
      }
      return Result.success([]);
    } catch (e) {
      return Result.error('Erro ao carregar calculadora: $e');
    }
  }

  Future<Result<void>> saveCalculatorItems(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_calculatorItemsKey, json.encode(data));
      return Result.success(null);
    } catch (e) {
      return Result.error('Erro ao salvar calculadora: $e');
    }
  }

  // Debts Sheets
  Future<Result<List<Map<String, dynamic>>>> loadDebtsSheets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_debtsSheetsKey);
      if (raw != null) {
        final decoded = json.decode(raw) as List;
        return Result.success(decoded.cast<Map<String, dynamic>>());
      }
      return Result.success([]);
    } catch (e) {
      return Result.error('Erro ao carregar dívidas: $e');
    }
  }

  Future<Result<void>> saveDebtsSheets(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_debtsSheetsKey, json.encode(data));
      return Result.success(null);
    } catch (e) {
      return Result.error('Erro ao salvar dívidas: $e');
    }
  }

  // Theme
  Future<Result<bool>> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      return Result.success(isDark);
    } catch (e) {
      return Result.error('Erro ao carregar tema: $e');
    }
  }

  Future<Result<void>> saveTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
      return Result.success(null);
    } catch (e) {
      return Result.error('Erro ao salvar tema: $e');
    }
  }

  // Paid Debts
  Future<Result<Set<String>>> loadPaidDebts(String sheetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'paid_debts_$sheetId';
      final list = prefs.getStringList(key) ?? [];
      return Result.success(list.toSet());
    } catch (e) {
      return Result.error('Erro ao carregar dívidas pagas: $e');
    }
  }

  Future<Result<void>> savePaidDebts(String sheetId, Set<String> paidIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'paid_debts_$sheetId';
      await prefs.setStringList(key, paidIds.toList());
      return Result.success(null);
    } catch (e) {
      return Result.error('Erro ao salvar dívidas pagas: $e');
    }
  }
}

// Result class for error handling
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.error(this.error)
      : data = null,
        isSuccess = false;
}
