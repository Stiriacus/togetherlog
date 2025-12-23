// TogetherLog - Single Full Layout Widget
// Hero layout for entries with 0-1 photos
// Scrapbook-style with Polaroid photo and decorative frame

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';

/// Single full layout - displays one large photo with text in a framed scrapbook page
class SingleFullLayout extends StatelessWidget {
  const SingleFullLayout({
    super.key,
    required this.entry,
    required this.colorScheme,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = entry.photos.isNotEmpty;
    final dateFormatter = DateFormat('MMMM d, yyyy');

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
              // Text header section - small at top
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
                  const SizedBox(height: 8),

                  // Highlight text
                  if (entry.highlightText.isNotEmpty)
                    Text(
                      entry.highlightText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Location
                  if (entry.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.location!.displayName,
                            style: TextStyle(
                              fontSize: 12,
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

              const SizedBox(height: 32),

              // Photo section - fills remaining space, aligned to top
              if (hasPhoto)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: PolaroidPhoto(
                      photoUrl: entry.photos.first.url,
                      colorScheme: colorScheme,
                      size: 380.0,
                    ),
                  ),
                ),

              // Spacer if no photo
              if (!hasPhoto) const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
