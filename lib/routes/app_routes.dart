import 'package:flutter/material.dart';
import '../modules/home/home_page.dart';
import '../modules/calculator/calculator_page.dart';
import '../modules/shopping_list/list_page.dart';
import '../modules/debts/debts_page.dart';
import '../modules/debts/debt_sheet_detail_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (_) => const HomePage(),
    '/calculator': (_) => const CalculatorPage(),
    '/shopping-list': (_) => const ShoppingListPage(),
    '/debts': (_) => const DebtsPage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name != null && settings.name!.startsWith('/debts/sheet/')) {
      final id = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (_) => DebtSheetDetailPage(sheetId: id),
      );
    }

    // fallback
    return MaterialPageRoute(builder: (_) => const HomePage());
  }
}
