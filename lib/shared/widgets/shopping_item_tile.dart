import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';

class ShoppingItemTile extends StatelessWidget {
  final String name;
  final bool checked;
  final bool isEditing;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  const ShoppingItemTile({
    super.key,
    required this.name,
    required this.checked,
    required this.isEditing,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: checked
            ? AppColors.success.withOpacity(0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: checked
              ? AppColors.success.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: checked,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            activeColor: AppColors.success,
          ),
        ),
        title: isEditing
            ? TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked ? AppColors.textSecondary : null,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: onSubmitted,
              )
            : GestureDetector(
                onTap: onTap,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color: checked ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: checked ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          color: AppColors.error,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}
