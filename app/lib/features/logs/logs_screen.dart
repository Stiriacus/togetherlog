// TogetherLog - Logs Screen
// Main screen for displaying and managing logs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/layouts/authenticated_shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
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
    return AuthenticatedShell(
      currentRoute: '/logs',
      child: Scaffold(
        backgroundColor: AppColors.antiqueWhite,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header zone - structural anchor for title
            Container(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Your Logs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            // Breathing space
            const SizedBox(height: AppSpacing.xl),

            // Primary content
            Expanded(
              child: LogList(
                onLogTap: (log) => _navigateToEntries(context, log),
                onLogEdit: (log) => _showEditDialog(context, log),
                onLogDelete: (log) => _showDeleteConfirmation(context, ref, log),
                onViewFlipbook: (log) => _navigateToFlipbook(context, log),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateDialog(context),
          icon: const Icon(AppIcons.add),
          label: const Text('New Log'),
        ),
      ),
    );
  }

  /// Navigate to entries screen for the selected log
  void _navigateToEntries(BuildContext context, Log log) {
    context.go('/logs/${log.id}/entries');
  }

  /// Navigate to flipbook viewer for the selected log
  void _navigateToFlipbook(BuildContext context, Log log) {
    context.go('/logs/${log.id}/flipbook?logName=${Uri.encodeComponent(log.name)}');
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
              backgroundColor: AppColors.errorMuted,
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
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete log: $e'),
            ),
          );
        }
      }
    }
  }
}
