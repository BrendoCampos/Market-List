import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'debts_controller.dart';
import 'debts_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/utils/export_helper.dart';
import '../../core/app_colors.dart';

class DebtsPage extends ConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);
    final sheets = state.sheets;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, state.errorMessage!, controller.clearError);
        controller.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dívidas Mensais'),
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: sheets.isEmpty
            ? const EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Nenhuma folha criada!',
                subtitle: 'Toque no botão "+" para começar.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sheets.length,
                itemBuilder: (_, index) {
                  final sheet = sheets[index];
                  final totalDebt = sheet.total;
                  final totalBudget = sheet.budget15 + sheet.budget30;
                  final remaining = totalBudget - totalDebt;
                  final isNegative = remaining < 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: isNegative
                          ? const LinearGradient(
                              colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isNegative
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.success.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isNegative ? AppColors.error : AppColors.success)
                              .withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/debts/sheet/${sheet.id}');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isNegative
                                          ? AppColors.error
                                          : AppColors.success,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sheet.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${sheet.debts.length} dívida(s)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.share_outlined),
                                            SizedBox(width: 12),
                                            Text('Compartilhar'),
                                          ],
                                        ),
                                        onTap: () => ExportHelper.exportDebtSheet(sheet),
                                      ),
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.copy_outlined),
                                            SizedBox(width: 12),
                                            Text('Duplicar'),
                                          ],
                                        ),
                                        onTap: () async {
                                          final confirm = await showConfirmationDialog(
                                            context,
                                            'Deseja duplicar esta folha?',
                                          );
                                          if (confirm) {
                                            final newSheet = DebtSheet(
                                              name: '${sheet.name} (Cópia)',
                                              budget15: sheet.budget15,
                                              budget30: sheet.budget30,
                                              debts: sheet.debts
                                                  .map((d) => DebtItem(
                                                        title: d.title,
                                                        value: d.value,
                                                        day: d.day,
                                                      ))
                                                  .toList(),
                                            );
                                            controller.addSheet(newSheet);
                                          }
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: Colors.red),
                                            SizedBox(width: 12),
                                            Text('Excluir', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                        onTap: () async {
                                          final confirm = await showConfirmationDialog(
                                            context,
                                            'Deseja excluir esta folha?',
                                          );
                                          if (confirm) {
                                            controller.removeSheet(sheet.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      label: 'Orçamento',
                                      value: 'R\$ ${totalBudget.toStringAsFixed(2)}',
                                      icon: Icons.account_balance,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoCard(
                                      label: 'Dívidas',
                                      value: 'R\$ ${totalDebt.toStringAsFixed(2)}',
                                      icon: Icons.trending_down,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isNegative
                                      ? AppColors.error.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isNegative ? Icons.warning_amber : Icons.check_circle,
                                          color: isNegative ? AppColors.error : AppColors.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isNegative ? 'Déficit' : 'Saldo',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isNegative ? AppColors.error : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'R\$ ${remaining.abs().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isNegative ? AppColors.error : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final novaFolha = DebtSheet(
            name: 'Nova Folha',
            budget15: 0,
            budget30: 0,
            debts: [],
          );
          controller.addSheet(novaFolha);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Folha'),
      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
