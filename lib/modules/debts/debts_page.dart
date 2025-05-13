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
      appBar: AppBar(title: const Text('Dívidas Mensais')),
      body: sheets.isEmpty
          ? const Center(child: Text('Nenhuma folha criada ainda!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sheets.length,
              itemBuilder: (_, index) {
                final sheet = sheets[index];
                final totalDebt = sheet.total;
                final totalBudget = sheet.budget15 + sheet.budget30;
                final restante = totalBudget - totalDebt;

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/debts/sheet/${sheet.id}');
                    },
                    title: Text(sheet.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total de Dívidas: R\$ ${totalDebt.toStringAsFixed(2)}'),
                        Text(
                            'Orçamento Total: R\$ ${totalBudget.toStringAsFixed(2)}'),
                        Text(
                          'Orçamento Restante: R\$ ${restante.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: restante < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
