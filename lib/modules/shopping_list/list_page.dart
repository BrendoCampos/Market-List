import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import 'list_controller.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final Map<int, bool> _editingTitles = {};
  final Map<String, bool> _editingItems = {};

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(shoppingListProvider);
    final controller = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Totalize')),
      body: lists.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma lista ainda!'),
                  SizedBox(height: 8),
                  Text('Use o botão abaixo para criar sua primeira lista.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lists.length,
              itemBuilder: (_, listIndex) {
                final list = lists[listIndex];
                final titleController = TextEditingController(text: list.title);
                final newItemController = TextEditingController();

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editingTitles[listIndex] == true
                              ? TextField(
                                  controller: titleController,
                                  autofocus: true,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  onSubmitted: (value) {
                                    controller.editListTitle(
                                        listIndex, value.trim());
                                    setState(() =>
                                        _editingTitles[listIndex] = false);
                                  },
                                  onEditingComplete: () {
                                    controller.editListTitle(
                                        listIndex, titleController.text.trim());
                                    setState(() =>
                                        _editingTitles[listIndex] = false);
                                  },
                                )
                              : GestureDetector(
                                  onTap: () => setState(
                                      () => _editingTitles[listIndex] = true),
                                  child: Text(
                                    list.title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          const SizedBox(height: 8),
                          ...List.generate(list.items.length, (itemIndex) {
                            final item = list.items[itemIndex];
                            final key = '${listIndex}_$itemIndex';
                            final itemController =
                                TextEditingController(text: item.name);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.checked,
                                    onChanged: (_) => controller.toggleItem(
                                        listIndex, itemIndex),
                                  ),
                                  Expanded(
                                    child: _editingItems[key] == true
                                        ? TextField(
                                            controller: itemController,
                                            autofocus: true,
                                            style: TextStyle(
                                              decoration: item.checked
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: item.checked
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                            onSubmitted: (value) {
                                              controller.editItemName(listIndex,
                                                  itemIndex, value.trim());
                                              setState(() =>
                                                  _editingItems[key] = false);
                                            },
                                            onEditingComplete: () {
                                              controller.editItemName(
                                                  listIndex,
                                                  itemIndex,
                                                  itemController.text.trim());
                                              setState(() =>
                                                  _editingItems[key] = false);
                                            },
                                          )
                                        : GestureDetector(
                                            onTap: () => setState(() =>
                                                _editingItems[key] = true),
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                decoration: item.checked
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: item.checked
                                                    ? Colors.grey
                                                    : null,
                                              ),
                                            ),
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
                                        controller.removeItem(
                                            listIndex, itemIndex);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: newItemController,
                                  decoration: const InputDecoration(
                                    hintText: 'Adicionar novo item...',
                                  ),
                                  onSubmitted: (value) {
                                    final name = value.trim();
                                    if (name.isNotEmpty) {
                                      controller.addItem(listIndex, name);
                                      newItemController.clear();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  final name = newItemController.text.trim();
                                  if (name.isNotEmpty) {
                                    controller.addItem(listIndex, name);
                                    newItemController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                final confirm = await showConfirmationDialog(
                                  context,
                                  'Deseja excluir esta lista?',
                                );
                                if (confirm) {
                                  controller.removeList(listIndex);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Excluir Lista',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Nova Lista'),
              content: TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título da lista'),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    controller.addList(titleController.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
