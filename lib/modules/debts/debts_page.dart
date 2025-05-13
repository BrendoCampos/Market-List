import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'debts_controller.dart';
import 'debts_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class DebtsPage extends ConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheets = ref.watch(debtsProvider);
    final controller = ref.read(debtsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dívidas Mensais'),
      ),
      body: sheets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhuma folha criada ainda.',
                      style: TextStyle(color: Colors.grey)),
                  Text('Use o botão "+" para começar.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sheets.length,
              itemBuilder: (_, index) {
                final sheet = sheets[index];
                final totalDebt = sheet.total;
                final totalBudget = sheet.budget15 + sheet.budget30;
                final restante = totalBudget - totalDebt;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    onTap: () {
                      Navigator.pushNamed(context, '/debts/sheet/${sheet.id}');
                    },
                    title: Text(
                      sheet.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Total de Dívidas: R\$ ${totalDebt.toStringAsFixed(2)}'),
                          Text(
                              'Orçamento: R\$ ${totalBudget.toStringAsFixed(2)}'),
                          Text(
                            'Restante: R\$ ${restante.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: restante < 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blue),
                          tooltip: 'Duplicar folha',
                          onPressed: () async {
                            final confirm = await showConfirmationDialog(
                              context,
                              'Deseja duplicar esta folha com todos os dados?',
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
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              if (context.mounted) {
                                Navigator.pushNamed(
                                    context, '/debts/sheet/${newSheet.id}');
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Excluir folha',
                          onPressed: () async {
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final novaFolha = DebtSheet(
            name: 'Nova Folha',
            budget15: 0,
            budget30: 0,
            debts: [],
          );
          controller.addSheet(novaFolha);
        },
        tooltip: 'Nova folha',
        child: const Icon(Icons.add),
      ),
    );
  }
}
