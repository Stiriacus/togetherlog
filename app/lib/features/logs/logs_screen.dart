// TogetherLog - Logs Screen
// Main screen for displaying and managing logs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_providers.dart';
import '../../data/models/log.dart';
import 'providers/logs_providers.dart';
import 'widgets/log_list.dart';
import 'widgets/create_log_dialog.dart';
import 'widgets/edit_log_dialog.dart';

/// Logs list screen with CRUD functionality
class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TogetherLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authRepository.signOut();
            },
          ),
        ],
      ),
      body: LogList(
        onLogTap: (log) => _navigateToEntries(context, log),
        onLogEdit: (log) => _showEditDialog(context, log),
        onLogDelete: (log) => _showDeleteConfirmation(context, ref, log),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Log'),
      ),
    );
  }

  /// Navigate to entries screen for the selected log
  void _navigateToEntries(BuildContext context, Log log) {
    context.go('/logs/${log.id}/entries');
  }

  /// Show create log dialog
  Future<void> _showCreateDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateLogDialog(),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Show edit log dialog
  Future<void> _showEditDialog(BuildContext context, Log log) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditLogDialog(log: log),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Log log,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: Text(
          'Are you sure you want to delete "${log.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final notifier = ref.read(logsNotifierProvider.notifier);
        await notifier.deleteLog(log.id);

        // Invalidate logs list to refresh
        ref.invalidate(logsListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete log: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
