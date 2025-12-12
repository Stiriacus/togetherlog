// TogetherLog - Entries Screen
// Displays entries for a specific log in chronological order

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/entries_providers.dart';
import 'widgets/entry_card.dart';

/// Entries list screen
/// Shows all entries for a log in chronological order (newest first)
class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({
    required this.logId,
    super.key,
  });

  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesListProvider(logId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entries'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/logs'),
        ),
        actions: [
          // View flipbook button (placeholder for MILESTONE 11)
          IconButton(
            icon: const Icon(Icons.auto_stories),
            tooltip: 'View Flipbook',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Flipbook viewer coming in MILESTONE 11'),
                ),
              );
            },
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }

          // Sort by event date (newest first)
          final sortedEntries = List.from(entries)
            ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(entriesListProvider(logId));
            },
            child: ListView.builder(
              itemCount: sortedEntries.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                return EntryCard(
                  entry: entry,
                  onTap: () => _navigateToDetail(context, entry.id),
                  onEdit: () => _navigateToEdit(context, entry.id),
                  onDelete: () => _showDeleteConfirmation(
                    context,
                    ref,
                    entry.id,
                    entry.highlightText,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load entries',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(entriesListProvider(logId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No entries yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first memory entry',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _navigateToCreate(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Entry'),
          ),
        ],
      ),
    );
  }

  /// Navigate to create entry screen
  void _navigateToCreate(BuildContext context) {
    context.push('/logs/$logId/entries/create');
  }

  /// Navigate to entry detail screen
  void _navigateToDetail(BuildContext context, String entryId) {
    context.push('/entries/$entryId');
  }

  /// Navigate to entry edit screen
  void _navigateToEdit(BuildContext context, String entryId) {
    context.push('/entries/$entryId/edit');
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String entryId,
    String highlightText,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete "$highlightText"? This action cannot be undone.',
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
        final notifier = ref.read(entryNotifierProvider.notifier);
        await notifier.deleteEntry(entryId);

        // Invalidate entries list to refresh
        ref.invalidate(entriesListProvider(logId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
