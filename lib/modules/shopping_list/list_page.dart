import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/utils/export_helper.dart';
import 'list_controller.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final Map<String, TextEditingController> _titleControllers = {};
  final Map<String, TextEditingController> _newItemControllers = {};
  final Map<String, bool> _editingItems = {};
  final Map<String, bool> _isExpanded = {};
  String _searchQuery = '';

  @override
  void dispose() {
    for (var controller in _titleControllers.values) {
      controller.dispose();
    }
    for (var controller in _newItemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shoppingListProvider);
    final controller = ref.read(shoppingListProvider.notifier);
    final lists = state.lists;

    // Show error message if exists
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, state.errorMessage!, controller.clearError);
        controller.clearError();
      });
    }

    final filteredLists = _searchQuery.isEmpty
        ? lists
        : lists.where((list) {
            final titleMatch = list.title.toLowerCase().contains(_searchQuery.toLowerCase());
            final itemMatch = list.items.any((item) => 
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()));
            return titleMatch || itemMatch;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _searchQuery.isEmpty
            ? const Text('Lista de Compras')
            : TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
        actions: [
          IconButton(
            icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.close),
            onPressed: () => setState(() => _searchQuery = ''),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: filteredLists.isEmpty
            ? EmptyState(
                icon: _searchQuery.isEmpty ? Icons.playlist_add_check : Icons.search_off,
                title: _searchQuery.isEmpty ? 'Nenhuma lista criada ainda!' : 'Nenhum resultado',
                subtitle: _searchQuery.isEmpty ? 'Toque no botão "+" para começar.' : 'Tente outro termo.',
              )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredLists.length,
              itemBuilder: (_, listIndex) {
                final list = filteredLists[listIndex];
                _titleControllers[list.id] ??=
                    TextEditingController(text: list.title);
                _newItemControllers[list.id] ??= TextEditingController();
                _isExpanded[list.id] ??= true;

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
                                            _titleControllers[list.id]
                                                    ?.text
                                                    .trim() ??
                                                '';
                                        controller.editListTitle(
                                            list.id, newTitle);
                                      }
                                    },
                                    child: TextField(
                                      controller: _titleControllers[list.id],
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
                              icon: Icon(_isExpanded[list.id]!
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onPressed: () {
                                setState(() {
                                  _isExpanded[list.id] =
                                      !_isExpanded[list.id]!;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () => ExportHelper.exportShoppingList(list),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showConfirmationDialog(
                                  context,
                                  'Deseja excluir esta lista?',
                                );
                                if (confirm) {
                                  _titleControllers[list.id]?.dispose();
                                  _titleControllers.remove(list.id);
                                  _newItemControllers[list.id]?.dispose();
                                  _newItemControllers.remove(list.id);
                                  controller.removeList(list.id);
                                }
                              },
                            ),
                          ],
                        ),
                        if (_isExpanded[list.id]!)
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
                                  final key = '${list.id}_${item.id}';
                                  final itemController =
                                      TextEditingController(text: item.name);

                                  return ListTile(
                                    leading: Checkbox(
                                      value: item.checked,
                                      onChanged: (_) {
                                        controller.toggleItem(list.id, item.id);
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
                                                  list.id,
                                                  item.id,
                                                  value.trim());
                                              setState(() =>
                                                  _editingItems[key] = false);
                                            },
                                            onEditingComplete: () {
                                              controller.editItemName(
                                                  list.id,
                                                  item.id,
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
                                          controller.removeItem(list.id, item.id);
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
                                          _newItemControllers[list.id],
                                      decoration: const InputDecoration(
                                        hintText: 'Escreva um novo item...',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) {
                                        final name = value.trim();
                                        if (name.isNotEmpty) {
                                          controller.addItem(list.id, name);
                                          _newItemControllers[list.id]
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
                                          _newItemControllers[list.id]
                                                  ?.text
                                                  .trim() ??
                                              '';
                                      if (name.isNotEmpty) {
                                        controller.addItem(list.id, name);
                                        _newItemControllers[list.id]?.clear();
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
