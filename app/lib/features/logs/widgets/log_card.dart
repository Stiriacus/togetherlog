// TogetherLog - Log Card Widget
// Displays a single log as a card

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/models/log.dart';

/// Card widget for displaying a single log
class LogCard extends StatelessWidget {
  const LogCard({
    required this.log,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onViewFlipbook,
    super.key,
  });

  final Log log;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewFlipbook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsMenu(context),
        borderRadius: BorderRadius.circular(AppRadius.rMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon based on log type
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.oliveWood.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.rMd),
                ),
                child: Icon(
                  _getTypeIcon(log.type),
                  color: _getTypeColor(log.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Log details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      log.type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getTypeColor(log.type),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Created ${dateFormat.format(log.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // More options icon
              IconButton(
                icon: const Icon(AppIcons.moreVert),
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show options menu (View Flipbook / Edit / Delete)
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.menuBook, color: AppColors.darkWalnut),
              title: const Text('View Flipbook'),
              onTap: () {
                Navigator.pop(context);
                onViewFlipbook();
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.delete, color: AppColors.errorMuted),
              title: const Text('Delete', style: TextStyle(color: AppColors.errorMuted)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon for log type
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'couple':
        return AppIcons.favorite;
      case 'family':
        return AppIcons.familyRestroom;
      case 'solo':
        return AppIcons.person;
      default:
        return AppIcons.book;
    }
  }

  /// Get color for log type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'couple':
        return AppColors.logTypeCouple;
      case 'family':
        return AppColors.logTypeFamily;
      case 'solo':
        return AppColors.oliveWood;
      default:
        return AppColors.oliveWood;
    }
  }
}
