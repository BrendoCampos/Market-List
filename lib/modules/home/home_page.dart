import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../shared/widgets/drawer_menu.dart';
import '../../shared/widgets/main_navigation.dart';
import '../shopping_list/list_controller.dart';
import '../calculator/calculator_controller.dart';
import '../debts/debts_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static void _navigateToTab(BuildContext context, int index) {
    final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
    mainNavState?.setIndex(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsState = ref.watch(shoppingListProvider);
    final calculatorState = ref.watch(calculatorProvider);
    final debtsState = ref.watch(debtsProvider);

    final totalLists = listsState.lists.length;
    final totalItems = calculatorState.items.length;
    final totalSheets = debtsState.sheets.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Totalize'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.waving_hand, size: 32, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Bem-vindo!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organize suas compras e finanças de forma inteligente',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 32),

            // Stats Cards
            Text(
              'Resumo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_cart,
                    title: 'Listas',
                    value: totalLists.toString(),
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calculate,
                    title: 'Itens',
                    value: totalItems.toString(),
                    color: AppColors.secondary,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.account_balance_wallet,
              title: 'Fichas de Dívidas',
              value: totalSheets.toString(),
              color: AppColors.accent,
              isWide: true,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _QuickActionCard(
              icon: Icons.add_shopping_cart,
              title: 'Nova Lista',
              subtitle: 'Crie uma lista de compras',
              gradient: AppColors.primaryGradient,
              onTap: () => _navigateToTab(context, 1),
            ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.calculate,
              title: 'Calcular Compras',
              subtitle: 'Some os valores dos produtos',
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
              ),
              onTap: () => _navigateToTab(context, 2),
            ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.attach_money,
              title: 'Gerenciar Dívidas',
              subtitle: 'Controle seu orçamento mensal',
              gradient: AppColors.accentGradient,
              onTap: () => _navigateToTab(context, 3),
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
