import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme_controller.dart';

class DrawerMenu extends ConsumerWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.orange),
            accountName: const Text('Totalize', style: TextStyle(fontSize: 20)),
            accountEmail: const Text('Organize suas compras 🛒'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.shopping_cart, color: Colors.orange, size: 32),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calculadora'),
            onTap: () => Navigator.pushNamed(context, '/calculator'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de Compras'),
            onTap: () => Navigator.pushNamed(context, '/shopping-list'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? 'Modo claro' : 'Modo escuro'),
            onTap: () => controller.toggleTheme(!isDark),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
