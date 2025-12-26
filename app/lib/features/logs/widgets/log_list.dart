// TogetherLog - Log List Widget
// Displays list of logs with loading and error states

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/models/log.dart';
import '../providers/logs_providers.dart';
import 'log_card.dart';

/// Widget for displaying list of logs
class LogList extends ConsumerWidget {
  const LogList({
    required this.onLogTap,
    required this.onLogEdit,
    required this.onLogDelete,
    required this.onViewScrapbook,
    super.key,
  });

  final Function(Log) onLogTap;
  final Function(Log) onLogEdit;
  final Function(Log) onLogDelete;
  final Function(Log) onViewScrapbook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsListProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return _buildEmptyState(context);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: RefreshIndicator(
              onRefresh: () async {
                // Invalidate the provider to trigger a refresh
                ref.invalidate(logsListProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: LogCard(
                      log: log,
                      onTap: () => onLogTap(log),
                      onEdit: () => onLogEdit(log),
                      onDelete: () => onLogDelete(log),
                      onViewScrapbook: () => onViewScrapbook(log),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, ref, error),
    );
  }

  /// Build empty state when no logs exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.book,
            size: AppIconSize.extraLarge,
            color: AppColors.emptyStateIcon,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No logs yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first memory book',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Loading your logs...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              AppIcons.error,
              size: AppIconSize.extraLarge,
              color: AppColors.errorMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load logs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Retry by invalidating the provider
                ref.invalidate(logsListProvider);
              },
              icon: const Icon(AppIcons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
