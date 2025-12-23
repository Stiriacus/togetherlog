// TogetherLog - Grid 2x2 Layout Widget
// Grid layout for entries with 2-4 photos
// Scrapbook-style with Polaroid photos and decorative frame

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';

/// Grid 2x2 layout - displays 2-4 photos scattered like a scrapbook page
class Grid2x2Layout extends StatelessWidget {
  const Grid2x2Layout({
    super.key,
    required this.entry,
    required this.colorScheme,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final photos = entry.photos.take(4).toList(); // Max 4 photos

    return Stack(
      children: [
        // Background surface
        Container(color: colorScheme.surface),

        // Decorative frame border
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF8B7355), // Warm brown frame
              width: 12,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Inner shadow for depth
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
        ),

        // Content inside frame with large padding
        Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text header section - compact at top
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    dateFormatter.format(entry.eventDate),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Highlight text
                  if (entry.highlightText.isNotEmpty)
                    Text(
                      entry.highlightText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Location
                  if (entry.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.location!.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Photo grid section - fills remaining space, anchored to top
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _buildPhotoGrid(photos),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid(List<Photo> photos) {
    // Scrapbook-style scattered Polaroid photos using Wrap
    // Anchored to top-left to fill the page naturally
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      children: photos.map((photo) {
        return PolaroidPhoto(
          photoUrl: photo.url,
          colorScheme: colorScheme,
          size: 220.0,
        );
      }).toList(),
    );
  }
}
