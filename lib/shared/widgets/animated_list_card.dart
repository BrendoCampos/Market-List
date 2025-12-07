import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';

class AnimatedListCard extends StatelessWidget {
  final String title;
  final int completedItems;
  final int totalItems;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final Widget child;
  final VoidCallback? onTitleTap;

  const AnimatedListCard({
    super.key,
    required this.title,
    required this.completedItems,
    required this.totalItems,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onShare,
    required this.onDelete,
    required this.child,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;
    final isComplete = completedItems == totalItems && totalItems > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isComplete
            ? const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? AppColors.success : AppColors.primary)
                .withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTitleTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isComplete
                                          ? AppColors.success
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$completedItems/$totalItems concluídos',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isComplete) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: onShare,
                        color: AppColors.primary,
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        onPressed: onToggleExpand,
                        color: AppColors.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            if (isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: child,
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
