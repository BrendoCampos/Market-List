import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'debts_controller.dart';
import 'debts_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/budget_pie_chart.dart';
import '../../shared/utils/validators.dart';
import '../../core/app_colors.dart';

class DebtSheetDetailPage extends ConsumerStatefulWidget {
  final String sheetId;
  const DebtSheetDetailPage({super.key, required this.sheetId});

  @override
  ConsumerState<DebtSheetDetailPage> createState() =>
      _DebtSheetDetailPageState();
}

class _DebtSheetDetailPageState extends ConsumerState<DebtSheetDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newDebtTitle = TextEditingController();
  final _newDebtValue = TextEditingController();
  int? _selectedDay;

  final _budget15Controller = TextEditingController();
  final _budget30Controller = TextEditingController();
  final _nameController = TextEditingController();

  final FocusNode _focusBudget15 = FocusNode();
  final FocusNode _focusBudget30 = FocusNode();

  bool _isChartsExpanded = true;

  @override
  void initState() {
    super.initState();
    _budget15Controller.text = '0.00';
    _budget30Controller.text = '0.00';

    _focusBudget15.addListener(() {
      if (!_focusBudget15.hasFocus) _saveBudgetField(day: 15);
    });
    _focusBudget30.addListener(() {
      if (!_focusBudget30.hasFocus) _saveBudgetField(day: 30);
    });
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _newDebtTitle.dispose();
    _newDebtValue.dispose();
    _budget15Controller.dispose();
    _budget30Controller.dispose();
    _nameController.dispose();
    _focusBudget15.dispose();
    _focusBudget30.dispose();
    super.dispose();
  }

  void _saveBudgetField({required int day}) {
    final controller = ref.read(debtsProvider.notifier);
    final sheet =
        ref.read(debtsProvider).sheets.firstWhere((s) => s.id == widget.sheetId);
    final controllerText =
        day == 15 ? _budget15Controller.text : _budget30Controller.text;
    final parsed = double.tryParse(controllerText.replaceAll(',', '.')) ?? 0.0;

    controller.editSheet(sheet.copyWith(
      budget15: day == 15 ? parsed : sheet.budget15,
      budget30: day == 30 ? parsed : sheet.budget30,
    ));
  }

  void _addNewDebt(DebtSheet sheet, DebtsController controller) {
    final updated = sheet.copyWith(
      debts: [
        ...sheet.debts,
        DebtItem(
          title: _newDebtTitle.text.trim(),
          value: double.parse(_newDebtValue.text.replaceAll(',', '.')),
          day: _selectedDay!,
        ),
      ],
    );
    controller.editSheet(updated);

    _newDebtTitle.clear();
    _newDebtValue.clear();
    _selectedDay = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);
    final sheets = state.sheets;
    
    // Show error message if exists
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, state.errorMessage!, controller.clearError);
        controller.clearError();
      });
    }
    
    final sheet = sheets.firstWhere((s) => s.id == widget.sheetId);

    final debts15 = sheet.debts.where((d) => d.day == 15).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debts30 = sheet.debts.where((d) => d.day == 30).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total15 = debts15.fold(0.0, (sum, d) => sum + d.value);
    final total30 = debts30.fold(0.0, (sum, d) => sum + d.value);
    final totalDebt = total15 + total30;
    final totalBudget = sheet.budget15 + sheet.budget30;

    _nameController.text = sheet.name;
    _budget15Controller.text = sheet.budget15.toStringAsFixed(2);
    _budget30Controller.text = sheet.budget30.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                sheet.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Editar nome',
              onPressed: () => _showEditNameDialog(sheet, controller),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Excluir folha',
            onPressed: () async {
              final confirm = await showConfirmationDialog(
                  context, 'Deseja excluir esta folha?');
              if (confirm) {
                controller.removeSheet(sheet.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Resumo Financeiro Collapsible
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isChartsExpanded = !_isChartsExpanded),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pie_chart,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Resumo Financeiro',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _isChartsExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isChartsExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 280,
                              child: BudgetPieChart(
                                title: 'Total Geral',
                                budget: totalBudget,
                                debt: totalDebt,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 280,
                              child: BudgetPieChart(
                                title: 'Dia 15',
                                budget: sheet.budget15,
                                debt: total15,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 280,
                              child: BudgetPieChart(
                                title: 'Dia 30',
                                budget: sheet.budget30,
                                debt: total30,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            _buildBudgetFields(),
            const SizedBox(height: 16),
            _buildAddDebtToggle(),
            const SizedBox(height: 12),
            _buildDebtList(
                sheet, controller, debts15, debts30, total15, total30),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.05), AppColors.secondary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Orçamentos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _budget15Controller,
                  focusNode: _focusBudget15,
                  decoration: const InputDecoration(
                    labelText: 'Dia 15',
                    prefixIcon: Icon(Icons.calendar_today, size: 20),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _budget30Controller,
                  focusNode: _focusBudget30,
                  decoration: const InputDecoration(
                    labelText: 'Dia 30',
                    prefixIcon: Icon(Icons.calendar_today, size: 20),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddDebtToggle() {
    return Center(
      child: FilledButton.icon(
        onPressed: () => _showAddDebtDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Dívida'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  void _showEditNameDialog(DebtSheet sheet, DebtsController controller) {
    _nameController.text = sheet.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Editar Nome da Folha'),
          ],
        ),
        content: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          validator: (v) => Validators.required(v, fieldName: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty && newName != sheet.name) {
                controller.editSheet(sheet.copyWith(name: newName));
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Dívida'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newDebtTitle,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => Validators.required(v, fieldName: 'Título'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newDebtValue,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveNumber(v, fieldName: 'Valor'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Dia de Vencimento',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('Dia 15')),
                  DropdownMenuItem(value: 30, child: Text('Dia 30')),
                ],
                onChanged: (val) => setState(() => _selectedDay = val),
                validator: (v) => v == null ? 'Selecione o dia' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newDebtTitle.clear();
              _newDebtValue.clear();
              _selectedDay = null;
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final sheet = ref.read(debtsProvider).sheets.firstWhere((s) => s.id == widget.sheetId);
                final controller = ref.read(debtsProvider.notifier);
                _addNewDebt(sheet, controller);
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(
    DebtSheet sheet,
    DebtsController controller,
    List<DebtItem> debts15,
    List<DebtItem> debts30,
    double total15,
    double total30,
  ) {
    Widget buildSection(String title, List<DebtItem> debts, double total, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (debts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 12, top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...debts.map((item) => _buildDebtTile(item, sheet, controller)).toList(),
          ]
        ],
      );
    }

    return Expanded(
      child: ListView(
        children: [
          buildSection('Dia 15', debts15, total15, AppColors.secondary),
          buildSection('Dia 30', debts30, total30, AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildDebtTile(
      DebtItem item, DebtSheet sheet, DebtsController controller) {
    final isPaid = controller.isDebtPaid(sheet.id, item.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isPaid
            ? const LinearGradient(colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)])
            : LinearGradient(
                colors: [
                  Colors.white,
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.togglePaidDebt(sheet.id, item.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPaid ? AppColors.success : AppColors.primary,
                      width: 2,
                    ),
                    color: isPaid ? AppColors.success : Colors.transparent,
                  ),
                  child: isPaid
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: isPaid ? TextDecoration.lineThrough : null,
                          color: isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'R\$ ${item.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Dia ${item.day}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                      onTap: () {
                        _newDebtTitle.text = item.title;
                        _newDebtValue.text = item.value.toStringAsFixed(2);
                        _selectedDay = item.day;
                        final updatedDebts = [...sheet.debts]..removeWhere((d) => d.id == item.id);
                        controller.editSheet(sheet.copyWith(debts: updatedDebts));
                        Future.delayed(const Duration(milliseconds: 100), _showAddDebtDialog);
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () async {
                        final confirm = await showConfirmationDialog(
                            context, 'Deseja excluir esta dívida?');
                        if (confirm) {
                          final updatedDebts = [...sheet.debts]..removeWhere((d) => d.id == item.id);
                          controller.editSheet(sheet.copyWith(debts: updatedDebts));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
