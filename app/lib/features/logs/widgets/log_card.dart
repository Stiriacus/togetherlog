// TogetherLog - Log Card Widget
// Displays a single log as a card

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/log.dart';

/// Card widget for displaying a single log
class LogCard extends StatelessWidget {
  const LogCard({
    required this.log,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Log log;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon based on log type
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTypeColor(log.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(log.type),
                  color: _getTypeColor(log.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

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
                    const SizedBox(height: 4),
                    Text(
                      log.type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getTypeColor(log.type),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${dateFormat.format(log.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // More options icon
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show options menu (Edit / Delete)
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        return Icons.favorite;
      case 'family':
        return Icons.family_restroom;
      case 'solo':
        return Icons.person;
      default:
        return Icons.book;
    }
  }

  /// Get color for log type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'couple':
        return Colors.pink;
      case 'family':
        return Colors.blue;
      case 'solo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
