import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    _budget15Controller.text = '0.00';
    _budget30Controller.text = '0.00';

    _focusBudget15.addListener(() {
      if (!_focusBudget15.hasFocus) {
        _saveBudgetField(day: 15);
      }
    });

    _focusBudget30.addListener(() {
      if (!_focusBudget30.hasFocus) {
        _saveBudgetField(day: 30);
      }
    });
  }

  void _saveBudgetField({required int day}) {
    final sheets = ref.read(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);
    final sheet = sheets.firstWhere((s) => s.id == widget.sheetId);

    final controllerText =
        day == 15 ? _budget15Controller.text : _budget30Controller.text;

    final parsedValue =
        double.tryParse(controllerText.replaceAll(',', '.')) ?? 0.0;

    controller.editSheet(
      sheet.copyWith(
        budget15: day == 15 ? parsedValue : sheet.budget15,
        budget30: day == 30 ? parsedValue : sheet.budget30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheets = ref.watch(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);
    final sheet = sheets.firstWhere((s) => s.id == widget.sheetId);

    final debts15 = sheet.debts.where((d) => d.day == 15).toList();
    final debts30 = sheet.debts.where((d) => d.day == 30).toList();
    final total15 = debts15.fold(0.0, (sum, d) => sum + d.value);
    final total30 = debts30.fold(0.0, (sum, d) => sum + d.value);

    final budget15 = sheet.budget15;
    final budget30 = sheet.budget30;
    final totalBudget = budget15 + budget30;
    final totalDebt = sheet.total;
    final totalRemaining = totalBudget - totalDebt;

    _nameController.text = sheet.name;
    _budget15Controller.text = budget15.toStringAsFixed(2);
    _budget30Controller.text = budget30.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: _isEditingName
            ? SizedBox(
                height: 40,
                child: TextField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveTitle(sheet, controller),
                  onEditingComplete: () => _saveTitle(sheet, controller),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nome da Folha',
                  ),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingName = true),
                child: Text(
                  sheet.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showConfirmationDialog(
                  context, 'Deseja excluir esta folha?');
              if (confirm) {
                controller.removeSheet(sheet.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total de Dívidas'),
                    Text(
                      'R\$ ${totalDebt.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saldo: R\$ ${totalRemaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: totalRemaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budget15Controller,
                    focusNode: _focusBudget15,
                    decoration:
                        const InputDecoration(labelText: 'Orçamento dia 15'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _budget30Controller,
                    focusNode: _focusBudget30,
                    decoration:
                        const InputDecoration(labelText: 'Orçamento dia 30'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
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
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedDay != null) {
                        final updated = sheet.copyWith(
                          debts: [
                            ...sheet.debts,
                            DebtItem(
                              title: _newDebtTitle.text.trim(),
                              value: double.parse(
                                  _newDebtValue.text.replaceAll(',', '.')),
                              day: _selectedDay!,
                            ),
                          ],
                        );
                        controller.editSheet(updated);
                        _newDebtTitle.clear();
                        _newDebtValue.clear();
                        setState(() => _selectedDay = null);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dívidas até dia 15: R\$ ${total15.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Dívidas até dia 30: R\$ ${total30.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Orçamento dia 15: R\$ ${budget15.toStringAsFixed(2)}'),
                  Text('Orçamento dia 30: R\$ ${budget30.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: sheet.debts.length,
                itemBuilder: (_, index) {
                  final item = sheet.debts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text('R\$ ${item.value} | dia ${item.day}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            child: const Text('Editar'),
                            onPressed: () {
                              _newDebtTitle.text = item.title;
                              _newDebtValue.text =
                                  item.value.toStringAsFixed(2);
                              setState(() => _selectedDay = item.day);
                              final updatedDebts = [...sheet.debts]
                                ..removeAt(index);
                              controller.editSheet(
                                  sheet.copyWith(debts: updatedDebts));
                            },
                          ),
                          TextButton(
                            child: const Text('Excluir'),
                            onPressed: () async {
                              final confirm = await showConfirmationDialog(
                                  context, 'Deseja excluir esta dívida?');
                              if (confirm) {
                                final updatedDebts = [...sheet.debts]
                                  ..removeAt(index);
                                controller.editSheet(
                                    sheet.copyWith(debts: updatedDebts));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTitle(DebtSheet sheet, DebtsController controller) {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != sheet.name) {
      controller.editSheet(sheet.copyWith(name: newName));
    }
    setState(() => _isEditingName = false);
  }
}
