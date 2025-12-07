import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';

class BudgetPieChart extends StatelessWidget {
  final String title;
  final double budget;
  final double debt;
  final Color color;

  const BudgetPieChart({
    super.key,
    required this.title,
    required this.budget,
    required this.debt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - debt;
    final usedPercentage = budget > 0 ? (debt / budget * 100) : 0;
    final isOverBudget = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? AppColors.error.withOpacity(0.3)
              : color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pie Chart
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: [
                      // Debt section
                      PieChartSectionData(
                        value: debt,
                        color: isOverBudget ? AppColors.error : AppColors.warning,
                        radius: 25,
                        title: '',
                      ),
                      // Remaining section
                      if (!isOverBudget)
                        PieChartSectionData(
                          value: remaining,
                          color: AppColors.success,
                          radius: 25,
                          title: '',
                        ),
                    ],
                  ),
                ),
                // Center percentage
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${usedPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? AppColors.error : color,
                      ),
                    ),
                    Text(
                      isOverBudget ? 'Excedido' : 'Usado',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Column(
            children: [
              _LegendItem(
                color: AppColors.info,
                label: 'Orçamento',
                value: 'R\$ ${budget.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: isOverBudget ? AppColors.error : AppColors.warning,
                label: 'Dívidas',
                value: 'R\$ ${debt.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOverBudget ? Icons.warning_amber : Icons.check_circle,
                          size: 16,
                          color: isOverBudget ? AppColors.error : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOverBudget ? 'Déficit' : 'Saldo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isOverBudget ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'R\$ ${remaining.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
