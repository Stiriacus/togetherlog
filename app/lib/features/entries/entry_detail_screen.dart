// TogetherLog - Entry Detail Screen
// View entry details with photos, tags, location, and Smart Page info

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/layouts/authenticated_shell.dart';
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

    return AuthenticatedShell(
      currentRoute: '/entries/$entryId',
      child: Scaffold(
        backgroundColor: AppColors.antiqueWhite,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header zone - structural anchor for title and actions
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.book),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Entry Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.edit),
                    tooltip: 'Edit Entry',
                    onPressed: () => context.push('/entries/$entryId/edit'),
                  ),
                ],
              ),
            ),

            // Breathing space
            const SizedBox(height: AppSpacing.xl),

            // Primary content
            Expanded(
              child: entryAsync.when(
        data: (entry) {
          final dateFormat = DateFormat('MMMM d, yyyy');

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Event Date
                Row(
                  children: [
                    Icon(
                      AppIcons.calendar,
                      color: AppColors.inactiveIcon,
                    ),
                    const SizedBox(width: AppSpacing.sm),
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

                const SizedBox(height: AppSpacing.md),

                // Highlight Text
                Text(
                  entry.highlightText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: AppSpacing.md),

                // Location
                if (entry.location != null) ...[
                  Row(
                    children: [
                      Icon(
                        entry.location!.isUserOverridden
                            ? AppIcons.editLocation
                            : AppIcons.location,
                        color: AppColors.inactiveIcon,
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.md),
                ],

                // Smart Page Status
                if (entry.isProcessed) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                              AppIcons.autoAwesome,
                              color: AppColors.successMuted,
                            ),
                            SizedBox(width: AppSpacing.sm),
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
                        const SizedBox(height: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.md),
                ],

                // Photos
                if (entry.photos.isNotEmpty) ...[
                  Text(
                    'Photos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: entry.photos.map((photo) {
                      return Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.oliveWood.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.rMd),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.rMd - 1),
                          child: Image.network(
                            photo.url,
                            width: 240,
                            height: 240,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.softApricot.withValues(alpha: 0.3),
                                child: Center(
                                  child: Icon(
                                    AppIcons.brokenImage,
                                    size: AppIconSize.large,
                                    color: AppColors.inactiveIcon,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: entry.tags.map((tag) {
                      return Chip(
                        label: Text(tag.name),
                      );
                    }).toList(),
                  ),
                ],
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.error,
                size: AppIconSize.extraLarge,
                color: AppColors.errorMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'Failed to load entry: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
