// TogetherLog - Entry Detail Screen
// View entry details with photos, tags, location, and Smart Page info

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'providers/entries_providers.dart';

/// Entry detail screen
/// Displays full entry details including all photos and metadata
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({
    required this.entryId,
    super.key,
  });

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(entryDetailProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => context.push('/entries/$entryId/edit'),
          ),
        ],
      ),
      body: entryAsync.when(
        data: (entry) {
          final dateFormat = DateFormat('MMMM d, yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.inactiveIcon,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(entry.eventDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Highlight Text
                Text(
                  entry.highlightText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                // Location
                if (entry.location != null) ...[
                  Row(
                    children: [
                      Icon(
                        entry.location!.isUserOverridden
                            ? Icons.edit_location
                            : Icons.location_on,
                        color: AppColors.inactiveIcon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.location!.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Smart Page Status
                if (entry.isProcessed) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.rMd),
                      border: Border.all(color: AppColors.successMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.successMuted,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Smart Page Generated',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (entry.pageLayoutType != null)
                          Text(
                            'Layout: ${entry.pageLayoutType}',
                            style: const TextStyle(color: AppColors.successMuted),
                          ),
                        if (entry.colorTheme != null)
                          Text(
                            'Theme: ${entry.colorTheme}',
                            style: const TextStyle(color: AppColors.successMuted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Photos
                if (entry.photos.isNotEmpty) ...[
                  Text(
                    'Photos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: entry.photos.length,
                    itemBuilder: (context, index) {
                      final photo = entry.photos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.rMd),
                        child: Image.network(
                          photo.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.softApricot.withValues(alpha: 0.3),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: AppIconSize.large,
                                  color: AppColors.inactiveIcon,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.tags.map((tag) {
                      return Chip(
                        label: Text(tag.name),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppIconSize.extraLarge,
                color: AppColors.errorMuted,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Failed to load entry: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
