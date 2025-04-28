import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calculator_controller.dart';
import 'calculator_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  final Map<int, TextEditingController> _descControllers = {};
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _priceControllers = {};

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(calculatorProvider);
    final controller = ref.read(calculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Compras'),
      ),
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
                          Text('Use o botão abaixo para adicionar um.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];

                        _descControllers[index] ??=
                            TextEditingController(text: item.description);
                        _qtyControllers[index] ??= TextEditingController(
                            text: item.quantity.toString());
                        _priceControllers[index] ??= TextEditingController(
                            text: item.price.toStringAsFixed(2));

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _descControllers[index],
                                  decoration: const InputDecoration(
                                    hintText: 'Descrição',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    controller.editItem(
                                      index,
                                      CalculatorItem(
                                        description: value,
                                        quantity: int.tryParse(
                                                _qtyControllers[index]?.text ??
                                                    '0') ??
                                            0,
                                        price: double.tryParse(
                                              (_priceControllers[index]?.text ??
                                                      '0.0')
                                                  .replaceAll(',', '.'),
                                            ) ??
                                            0.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _qtyControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Qtd',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    controller.editItem(
                                      index,
                                      CalculatorItem(
                                        description:
                                            _descControllers[index]?.text ?? '',
                                        quantity: int.tryParse(value) ?? 0,
                                        price: double.tryParse(
                                              (_priceControllers[index]?.text ??
                                                      '0.0')
                                                  .replaceAll(',', '.'),
                                            ) ??
                                            0.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: _priceControllers[index],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    hintText: 'Preço',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    final formatted =
                                        value.replaceAll(',', '.');
                                    controller.editItem(
                                      index,
                                      CalculatorItem(
                                        description:
                                            _descControllers[index]?.text ?? '',
                                        quantity: int.tryParse(
                                                _qtyControllers[index]?.text ??
                                                    '0') ??
                                            0,
                                        price:
                                            double.tryParse(formatted) ?? 0.0,
                                      ),
                                    );
                                  },
                                ),
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
                                    _descControllers.remove(index);
                                    _qtyControllers.remove(index);
                                    _priceControllers.remove(index);
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
            const SizedBox(height: 16),
            Text(
              'Total: R\$ ${controller.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: items.isNotEmpty
                  ? () async {
                      final confirm = await showConfirmationDialog(
                        context,
                        'Deseja limpar todos os itens da calculadora?',
                      );
                      if (confirm) {
                        _descControllers.clear();
                        _qtyControllers.clear();
                        _priceControllers.clear();
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
        onPressed: () {
          controller.addItem(
            CalculatorItem(description: '', quantity: 0, price: 0.0),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
