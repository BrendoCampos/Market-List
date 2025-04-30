import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import 'list_controller.dart';
import 'list_model.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final Map<int, TextEditingController> _titleControllers = {};
  final Map<int, TextEditingController> _newItemControllers = {};
  final Map<String, bool> _editingItems = {};
  final Map<int, bool> _isExpanded = {};

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(shoppingListProvider);
    final controller = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Compras')),
      body: lists.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add_check, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma lista criada ainda!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Toque no botão "+" para começar.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lists.length,
              itemBuilder: (_, listIndex) {
                final list = lists[listIndex];
                _titleControllers[listIndex] ??=
                    TextEditingController(text: list.title);
                _newItemControllers[listIndex] ??= TextEditingController();
                _isExpanded[listIndex] ??= true;

                final totalItems = list.items.length;
                final completedItems =
                    list.items.where((item) => item.checked).length;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Cabeçalho da Lista
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Focus(
                                    onFocusChange: (hasFocus) {
                                      if (!hasFocus) {
                                        final newTitle =
                                            _titleControllers[listIndex]
                                                    ?.text
                                                    .trim() ??
                                                '';
                                        controller.editListTitle(
                                            listIndex, newTitle);
                                      }
                                    },
                                    child: TextField(
                                      controller: _titleControllers[listIndex],
                                      decoration: const InputDecoration(
                                        hintText: 'Título da Lista',
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$completedItems/$totalItems concluídos',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isExpanded[listIndex]!
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onPressed: () {
                                setState(() {
                                  _isExpanded[listIndex] =
                                      !_isExpanded[listIndex]!;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showConfirmationDialog(
                                  context,
                                  'Deseja excluir esta lista?',
                                );
                                if (confirm) {
                                  _titleControllers.remove(listIndex);
                                  controller.removeList(listIndex);
                                }
                              },
                            ),
                          ],
                        ),
                        if (_isExpanded[listIndex]!)
                          Column(
                            children: [
                              const Divider(),
                              AnimatedList(
                                key: GlobalKey<AnimatedListState>(),
                                shrinkWrap: true,
                                initialItemCount: list.items.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, itemIndex, __) {
                                  final orderedItems = [
                                    ...list.items.where((e) => !e.checked),
                                    ...list.items.where((e) => e.checked),
                                  ];
                                  final item = orderedItems[itemIndex];
                                  final key = '${listIndex}_$itemIndex';
                                  final itemController =
                                      TextEditingController(text: item.name);

                                  return ListTile(
                                    leading: Checkbox(
                                      value: item.checked,
                                      onChanged: (_) {
                                        controller.toggleItem(listIndex,
                                            list.items.indexOf(item));
                                      },
                                    ),
                                    title: _editingItems[key] == true
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
                                              controller.editItemName(
                                                  listIndex,
                                                  list.items.indexOf(item),
                                                  value.trim());
                                              setState(() =>
                                                  _editingItems[key] = false);
                                            },
                                            onEditingComplete: () {
                                              controller.editItemName(
                                                  listIndex,
                                                  list.items.indexOf(item),
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
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirm =
                                            await showConfirmationDialog(
                                          context,
                                          'Deseja excluir este item?',
                                        );
                                        if (confirm) {
                                          controller.removeItem(listIndex,
                                              list.items.indexOf(item));
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          _newItemControllers[listIndex],
                                      decoration: const InputDecoration(
                                        hintText: 'Escreva um novo item...',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) {
                                        final name = value.trim();
                                        if (name.isNotEmpty) {
                                          controller.addItem(listIndex, name);
                                          _newItemControllers[listIndex]
                                              ?.clear();
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.green),
                                    onPressed: () {
                                      final name =
                                          _newItemControllers[listIndex]
                                                  ?.text
                                                  .trim() ??
                                              '';
                                      if (name.isNotEmpty) {
                                        controller.addItem(listIndex, name);
                                        _newItemControllers[listIndex]?.clear();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addList('Nova Lista');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
