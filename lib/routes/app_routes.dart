import 'package:flutter/material.dart';
import '../modules/home/home_page.dart';
import '../modules/calculator/calculator_page.dart';
import '../modules/shopping_list/list_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (_) => const HomePage(),
    '/calculator': (_) => const CalculatorPage(),
    '/shopping-list': (_) => const ShoppingListPage(),
  };
}
