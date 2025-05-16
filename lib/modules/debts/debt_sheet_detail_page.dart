import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'debts_controller.dart';
import 'debts_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';

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

  bool _isEditingName = false;
  bool _isAddingNewDebt = false;

  Set<String> _paidDebtIds = {};

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

    _loadPaidDebts();
  }

  Future<void> _loadPaidDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'paid_debts_${widget.sheetId}';
    final list = prefs.getStringList(key) ?? [];
    setState(() {
      _paidDebtIds = list.toSet();
    });
  }

  Future<void> _savePaidDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'paid_debts_${widget.sheetId}';
    await prefs.setStringList(key, _paidDebtIds.toList());
  }

  void _saveBudgetField({required int day}) {
    final controller = ref.read(debtsProvider.notifier);
    final sheet =
        ref.read(debtsProvider).firstWhere((s) => s.id == widget.sheetId);
    final controllerText =
        day == 15 ? _budget15Controller.text : _budget30Controller.text;
    final parsed = double.tryParse(controllerText.replaceAll(',', '.')) ?? 0.0;

    controller.editSheet(sheet.copyWith(
      budget15: day == 15 ? parsed : sheet.budget15,
      budget30: day == 30 ? parsed : sheet.budget30,
    ));
  }

  void _addNewDebt(DebtSheet sheet, DebtsController controller) {
    if (_formKey.currentState!.validate() && _selectedDay != null) {
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
      setState(() => _isAddingNewDebt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheets = ref.watch(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);
    final sheet = sheets.firstWhere((s) => s.id == widget.sheetId);

    final debts15 = sheet.debts.where((d) => d.day == 15).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debts30 = sheet.debts.where((d) => d.day == 30).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total15 = debts15.fold(0.0, (sum, d) => sum + d.value);
    final total30 = debts30.fold(0.0, (sum, d) => sum + d.value);
    final totalDebt = total15 + total30;
    final totalBudget = sheet.budget15 + sheet.budget30;
    final totalRemaining = totalBudget - totalDebt;

    _nameController.text = sheet.name;
    _budget15Controller.text = sheet.budget15.toStringAsFixed(2);
    _budget30Controller.text = sheet.budget30.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: _isEditingName
            ? TextField(
                controller: _nameController,
                autofocus: true,
                onEditingComplete: () {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty && newName != sheet.name) {
                    controller.editSheet(sheet.copyWith(name: newName));
                  }
                  setState(() => _isEditingName = false);
                },
                decoration: const InputDecoration(border: InputBorder.none),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingName = true),
                child: Text(sheet.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
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
            ExpansionTile(
              initiallyExpanded: false,
              title: const Text('Resumo Financeiro'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: [
                _buildTopCard(totalDebt, totalRemaining),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTopCardCustom(
                        title: 'Dívidas dia 15',
                        total: total15,
                        saldo: sheet.budget15 - total15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTopCardCustom(
                        title: 'Dívidas dia 30',
                        total: total30,
                        saldo: sheet.budget30 - total30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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

  Widget _buildTopCard(double total, double saldo) {
    return _buildTopCardCustom(
        title: 'Total de Dívidas', total: total, saldo: saldo);
  }

  Widget _buildTopCardCustom(
      {required String title, required double total, required double saldo}) {
    return Card(
      color: Colors.purple.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              'R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saldo: R\$ ${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: saldo >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _budget15Controller,
            focusNode: _focusBudget15,
            decoration: const InputDecoration(labelText: 'Orçamento dia 15'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _budget30Controller,
            focusNode: _focusBudget30,
            decoration: const InputDecoration(labelText: 'Orçamento dia 30'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildAddDebtToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isAddingNewDebt
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Center(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isAddingNewDebt = true),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar nova dívida'),
            ),
          ),
          secondChild: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _newDebtTitle,
                    decoration: const InputDecoration(labelText: 'Dívida'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _newDebtValue,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v!.replaceAll(',', '.')) == null
                            ? 'Inválido'
                            : null,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedDay,
                  hint: const Text("Dia"),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text("15")),
                    DropdownMenuItem(value: 30, child: Text("30")),
                  ],
                  onChanged: (val) => setState(() => _selectedDay = val),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: 'Salvar dívida',
                  onPressed: () {
                    final sheet = ref
                        .read(debtsProvider)
                        .firstWhere((s) => s.id == widget.sheetId);
                    final controller = ref.read(debtsProvider.notifier);
                    _addNewDebt(sheet, controller);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
    Widget buildSection(String title, List<DebtItem> debts, double total) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (debts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...debts
                .map((item) => _buildDebtTile(item, sheet, controller))
                .toList(),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text('Total: R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ]
        ],
      );
    }

    return Expanded(
      child: ListView(
        children: [
          buildSection('📅 Dívidas do dia 15', debts15, total15),
          buildSection('📅 Dívidas do dia 30', debts30, total30),
        ],
      ),
    );
  }

  Widget _buildDebtTile(
      DebtItem item, DebtSheet sheet, DebtsController controller) {
    final isPaid = _paidDebtIds.contains(item.id);
    return Card(
      elevation: 1,
      color: isPaid ? Colors.green.shade100 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Checkbox(
          value: isPaid,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _paidDebtIds.add(item.id);
              } else {
                _paidDebtIds.remove(item.id);
              }
              _savePaidDebts();
            });
          },
        ),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle:
            Text('R\$ ${item.value.toStringAsFixed(2)} | dia ${item.day}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              tooltip: 'Editar',
              onPressed: () {
                _newDebtTitle.text = item.title;
                _newDebtValue.text = item.value.toStringAsFixed(2);
                setState(() {
                  _selectedDay = item.day;
                  _isAddingNewDebt = true;
                });
                final updatedDebts = [...sheet.debts]
                  ..removeWhere((d) => d.id == item.id);
                controller.editSheet(sheet.copyWith(debts: updatedDebts));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Excluir',
              onPressed: () async {
                final confirm = await showConfirmationDialog(
                    context, 'Deseja excluir esta dívida?');
                if (confirm) {
                  final updatedDebts = [...sheet.debts]
                    ..removeWhere((d) => d.id == item.id);
                  controller.editSheet(sheet.copyWith(debts: updatedDebts));
                  _paidDebtIds.remove(item.id);
                  _savePaidDebts();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
