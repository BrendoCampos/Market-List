import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_repository.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(),
);

class ThemeController extends StateNotifier<ThemeMode> {
  final StorageRepository _repository = StorageRepository();

  ThemeController() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() async {
    final result = await _repository.loadTheme();
    if (result.isSuccess) {
      state = result.data! ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await _repository.saveTheme(isDark);
  }
}
