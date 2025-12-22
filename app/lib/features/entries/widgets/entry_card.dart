// TogetherLog - Entry Card Widget
// Displays an entry preview in a list

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entry.dart';

/// Entry Card Widget
/// Displays entry preview with photo, date, highlight text, and location
class EntryCard extends StatelessWidget {
  const EntryCard({
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Entry entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final hasPhotos = entry.photos.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.rMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo thumbnail (if available)
            if (hasPhotos)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  entry.photos.first.thumbnailUrl,
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.softApricot.withValues(alpha: 0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Entry content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppIconSize.small,
                        color: AppColors.inactiveIcon,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(entry.eventDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Highlight text
                  Text(
                    entry.highlightText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Location (if available)
                  if (entry.location != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: AppIconSize.small,
                          color: AppColors.inactiveIcon,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.location!.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Photo count and Smart Page status
                  Row(
                    children: [
                      // Photo count
                      if (hasPhotos)
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: AppIconSize.small,
                              color: AppColors.inactiveIcon,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.photos.length} photo${entry.photos.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Smart Page processed indicator
                      if (entry.isProcessed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successMuted.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.rFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: AppColors.successMuted,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Smart Page',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.successMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            if (onEdit != null || onDelete != null)
              const Divider(height: 1),
            if (onEdit != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.errorMuted,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
