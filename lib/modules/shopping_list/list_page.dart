import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/animated_list_card.dart';
import '../../shared/widgets/shopping_item_tile.dart';
import '../../shared/utils/export_helper.dart';
import '../../core/app_colors.dart';
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
            ? const Text('Minhas Listas')
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
                icon: _searchQuery.isEmpty ? Icons.shopping_cart_outlined : Icons.search_off,
                title: _searchQuery.isEmpty ? 'Nenhuma lista criada!' : 'Nenhum resultado',
                subtitle: _searchQuery.isEmpty ? 'Toque no botão "+" para começar.' : 'Tente outro termo.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredLists.length,
                itemBuilder: (_, index) {
                  final list = filteredLists[index];
                  _titleControllers[list.id] ??= TextEditingController(text: list.title);
                  _newItemControllers[list.id] ??= TextEditingController();
                  _isExpanded[list.id] ??= true;

                  final totalItems = list.items.length;
                  final completedItems = list.items.where((item) => item.checked).length;

                  return AnimatedListCard(
                    title: list.title,
                    completedItems: completedItems,
                    totalItems: totalItems,
                    isExpanded: _isExpanded[list.id]!,
                    onToggleExpand: () {
                      setState(() => _isExpanded[list.id] = !_isExpanded[list.id]!);
                    },
                    onShare: () => ExportHelper.exportShoppingList(list),
                    onDelete: () async {
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
                    onTitleTap: () => _showEditTitleDialog(context, list.id, list.title),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        // Items List
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ...list.items.map((item) {
                                final key = '${list.id}_${item.id}';
                                final itemController = TextEditingController(text: item.name);
                                
                                return ShoppingItemTile(
                                  name: item.name,
                                  checked: item.checked,
                                  isEditing: _editingItems[key] == true,
                                  onToggle: () => controller.toggleItem(list.id, item.id),
                                  onTap: () => setState(() => _editingItems[key] = true),
                                  onDelete: () async {
                                    final confirm = await showConfirmationDialog(
                                      context,
                                      'Deseja excluir este item?',
                                    );
                                    if (confirm) {
                                      controller.removeItem(list.id, item.id);
                                    }
                                  },
                                  controller: itemController,
                                  onSubmitted: (value) {
                                    controller.editItemName(list.id, item.id, value.trim());
                                    setState(() => _editingItems[key] = false);
                                  },
                                );
                              }),
                              const SizedBox(height: 12),
                              // Add New Item
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _newItemControllers[list.id],
                                        decoration: const InputDecoration(
                                          hintText: 'Adicionar item...',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          final name = value.trim();
                                          if (name.isNotEmpty) {
                                            controller.addItem(list.id, name);
                                            _newItemControllers[list.id]?.clear();
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: AppColors.primary,
                                      onPressed: () {
                                        final name = _newItemControllers[list.id]?.text.trim() ?? '';
                                        if (name.isNotEmpty) {
                                          controller.addItem(list.id, name);
                                          _newItemControllers[list.id]?.clear();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  void _showAddListDialog(BuildContext context) {
    final controller = ref.read(shoppingListProvider.notifier);
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da lista',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.addList(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.addList(textController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context, String listId, String currentTitle) {
    final controller = ref.read(shoppingListProvider.notifier);
    final textController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Título'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Título da lista',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.editListTitle(listId, value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.editListTitle(listId, textController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
