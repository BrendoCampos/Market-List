import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'calculator_controller.dart';
import 'calculator_model.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/utils/export_helper.dart';
import '../../core/app_colors.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  final Map<String, TextEditingController> _descControllers = {};
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void dispose() {
    for (var controller in _descControllers.values) {
      controller.dispose();
    }
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final controller = ref.read(calculatorProvider.notifier);
    final items = state.items;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, state.errorMessage!, controller.clearError);
        controller.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirm = await showConfirmationDialog(
                  context,
                  'Deseja limpar todos os itens?',
                );
                if (confirm) {
                  controller.clearAll();
                  for (var c in _descControllers.values) {
                    c.dispose();
                  }
                  for (var c in _qtyControllers.values) {
                    c.dispose();
                  }
                  for (var c in _priceControllers.values) {
                    c.dispose();
                  }
                  _descControllers.clear();
                  _qtyControllers.clear();
                  _priceControllers.clear();
                }
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: Column(
          children: [
            // Total Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${controller.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ExportHelper.exportCalculator(items, controller.total),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        'Compartilhar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

            // Items List
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.calculate_outlined,
                      title: 'Nenhum item adicionado!',
                      subtitle: 'Toque no botão "+" para começar.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        _descControllers[item.id] ??= TextEditingController(text: item.description);
                        _qtyControllers[item.id] ??= TextEditingController(text: item.quantity.toString());
                        _priceControllers[item.id] ??= TextEditingController(text: item.price.toStringAsFixed(2));

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _descControllers[item.id],
                                      decoration: const InputDecoration(
                                        hintText: 'Produto',
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onChanged: (value) => _updateItem(item, controller),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: AppColors.error,
                                    onPressed: () async {
                                      final confirm = await showConfirmationDialog(
                                        context,
                                        'Deseja remover este item?',
                                      );
                                      if (confirm) {
                                        controller.removeItemById(item.id);
                                        _descControllers[item.id]?.dispose();
                                        _descControllers.remove(item.id);
                                        _qtyControllers[item.id]?.dispose();
                                        _qtyControllers.remove(item.id);
                                        _priceControllers[item.id]?.dispose();
                                        _priceControllers.remove(item.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.shopping_basket_outlined, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _qtyControllers[item.id],
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                hintText: 'Qtd',
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (value) => _updateItem(item, controller),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('×', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('R\$', style: TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _priceControllers[item.id],
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                hintText: '0.00',
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (value) => _updateItem(item, controller),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Subtotal:',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'R\$ ${item.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final newItem = CalculatorItem(description: '', quantity: 1, price: 0.0);
          controller.addItem(newItem);
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  void _updateItem(CalculatorItem item, CalculatorController controller) {
    controller.editItem(
      item.id,
      CalculatorItem(
        id: item.id,
        description: _descControllers[item.id]?.text ?? '',
        quantity: int.tryParse(_qtyControllers[item.id]?.text ?? '0') ?? 0,
        price: double.tryParse(_priceControllers[item.id]?.text.replaceAll(',', '.') ?? '0') ?? 0,
      ),
    );
  }
}
