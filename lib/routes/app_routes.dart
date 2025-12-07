import 'package:flutter/material.dart';
import '../shared/widgets/main_navigation.dart';
import '../modules/debts/debt_sheet_detail_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (_) => const MainNavigation(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name != null && settings.name!.startsWith('/debts/sheet/')) {
      final id = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (_) => DebtSheetDetailPage(sheetId: id),
      );
    }

    // fallback
    return MaterialPageRoute(builder: (_) => const MainNavigation());
  }
}
