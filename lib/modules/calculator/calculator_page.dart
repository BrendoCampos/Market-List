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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final Map<String, TextEditingController> _descControllers = {};
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

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
        child: items.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Nenhum item adicionado!'),
                    SizedBox(height: 8),
                    Text('Use o botão abaixo para adicionar um.'),
                  ],
                ),
              )
            : Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text('Descrição',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: Text('Qtd',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Text('Preço',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                  const Divider(thickness: 1.2),
                  Expanded(
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: items.length,
                      itemBuilder: (_, index, animation) {
                        final item = items[index];
                        _descControllers[item.id] ??=
                            TextEditingController(text: item.description);
                        _qtyControllers[item.id] ??= TextEditingController(
                            text: item.quantity.toString());
                        _priceControllers[item.id] ??= TextEditingController(
                            text: item.price.toStringAsFixed(2));

                        return SizeTransition(
                          sizeFactor: animation,
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _descControllers[item.id],
                                      decoration: const InputDecoration(
                                        hintText: 'Produto',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        controller.editItem(
                                          item.id,
                                          CalculatorItem(
                                            id: item.id,
                                            description: value,
                                            quantity: int.tryParse(
                                                    _qtyControllers[item.id]
                                                            ?.text ??
                                                        '0') ??
                                                0,
                                            price: double.tryParse(
                                                    _priceControllers[item.id]
                                                            ?.text
                                                            .replaceAll(
                                                                ',', '.') ??
                                                        '0') ??
                                                0,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: _qtyControllers[item.id],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: 'Qtd',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        controller.editItem(
                                          item.id,
                                          CalculatorItem(
                                            id: item.id,
                                            description:
                                                _descControllers[item.id]
                                                        ?.text ??
                                                    '',
                                            quantity: int.tryParse(value) ?? 0,
                                            price: double.tryParse(
                                                    _priceControllers[item.id]
                                                            ?.text
                                                            .replaceAll(
                                                                ',', '.') ??
                                                        '0') ??
                                                0,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _priceControllers[item.id],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: 'Preço',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        final formatted =
                                            value.replaceAll(',', '.');
                                        controller.editItem(
                                          item.id,
                                          CalculatorItem(
                                            id: item.id,
                                            description:
                                                _descControllers[item.id]
                                                        ?.text ??
                                                    '',
                                            quantity: int.tryParse(
                                                    _qtyControllers[item.id]
                                                            ?.text ??
                                                        '0') ??
                                                0,
                                            price:
                                                double.tryParse(formatted) ?? 0,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm =
                                          await showConfirmationDialog(
                                        context,
                                        'Deseja remover este item?',
                                      );
                                      if (confirm) {
                                        final indexToRemove = items
                                            .indexWhere((e) => e.id == item.id);

                                        _listKey.currentState?.removeItem(
                                          indexToRemove,
                                          (context, animation) =>
                                              _buildRemovedItemCard(
                                                  item, animation),
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );

                                        await Future.delayed(
                                            const Duration(milliseconds: 300));

                                        controller.removeItemById(item.id);
                                        _descControllers.remove(item.id);
                                        _qtyControllers.remove(item.id);
                                        _priceControllers.remove(item.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 12),
                  Text(
                    'Total: R\$ ${controller.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: items.isNotEmpty
                        ? () async {
                            final confirm = await showConfirmationDialog(
                              context,
                              'Deseja limpar todos os itens?',
                            );
                            if (confirm) {
                              controller.clearAll();
                              _descControllers.clear();
                              _qtyControllers.clear();
                              _priceControllers.clear();
                              _listKey.currentState?.setState(() {});
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.red.withOpacity(0.3),
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Limpar Tudo'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newItem =
              CalculatorItem(description: '', quantity: 0, price: 0.0);
          controller.addItem(newItem);
          final length = ref.read(calculatorProvider).length;
          _listKey.currentState?.insertItem(length - 1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemovedItemCard(
      CalculatorItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(item.description),
          subtitle:
              Text('${item.quantity} x R\$ ${item.price.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}
