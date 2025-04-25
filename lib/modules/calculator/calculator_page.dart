import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calculator_model.dart';
import 'calculator_controller.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(calculatorProvider);
    final controller = ref.read(calculatorProvider.notifier);
    final hasItems = items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhum item adicionado!'),
                          SizedBox(height: 8),
                          Text('Toque no botão abaixo para adicionar um.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          title:
                              Text('${item.description} (x${item.quantity})'),
                          subtitle:
                              Text('R\$ ${item.price.toStringAsFixed(2)} cada'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  final descController = TextEditingController(
                                      text: item.description);
                                  final qtyController = TextEditingController(
                                      text: item.quantity.toString());
                                  final priceController = TextEditingController(
                                      text: item.price.toStringAsFixed(2));

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    builder: (_) => Padding(
                                      padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 24,
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Editar Item',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: descController,
                                            decoration: const InputDecoration(
                                                labelText: 'Descrição'),
                                          ),
                                          TextField(
                                            controller: qtyController,
                                            decoration: const InputDecoration(
                                                labelText: 'Quantidade'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextField(
                                            controller: priceController,
                                            decoration: const InputDecoration(
                                                labelText: 'Preço'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.save),
                                            label: const Text('Salvar'),
                                            onPressed: () {
                                              final desc =
                                                  descController.text.trim();
                                              final qty = int.tryParse(
                                                      qtyController.text) ??
                                                  item.quantity;
                                              final price = double.tryParse(
                                                      priceController.text
                                                          .replaceAll(
                                                              ',', '.')) ??
                                                  item.price;

                                              if (desc.isNotEmpty) {
                                                ref
                                                    .read(calculatorProvider
                                                        .notifier)
                                                    .editItem(
                                                      index,
                                                      CalculatorItem(
                                                        description: desc,
                                                        quantity: qty,
                                                        price: price,
                                                      ),
                                                    );
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showConfirmationDialog(
                                    context,
                                    'Deseja remover este item?',
                                  );
                                  if (confirm) {
                                    controller.removeItem(index);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total da compra: R\$ ${controller.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: hasItems
                  ? () async {
                      final confirm = await showConfirmationDialog(
                        context,
                        'Deseja limpar todos os itens da calculadora?',
                      );
                      if (confirm) {
                        controller.clearAll();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.red.withOpacity(0.3),
                disabledForegroundColor: Colors.white.withOpacity(0.5),
              ),
              child: const Text('Limpar Tudo'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final descController = TextEditingController();
          final qtyController = TextEditingController();
          final priceController = TextEditingController();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Adicionar Item',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Preço'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Adicionar'),
                    onPressed: () {
                      final desc = descController.text.trim();
                      final qty = int.tryParse(qtyController.text) ?? 1;
                      final price = double.tryParse(
                              priceController.text.replaceAll(',', '.')) ??
                          0.0;

                      if (desc.isNotEmpty) {
                        controller.addItem(
                          CalculatorItem(
                              description: desc, quantity: qty, price: price),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
