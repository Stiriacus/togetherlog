// TogetherLog - Grid 3x2 Layout Widget
// Grid layout for entries with 5-6 photos
// Scrapbook-style with Polaroid photos and decorative frame

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';

/// Grid 3x2 layout - displays 5-6 photos scattered like a full scrapbook page
class Grid3x2Layout extends StatelessWidget {
  const Grid3x2Layout({
    super.key,
    required this.entry,
    required this.colorScheme,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final photos = entry.photos.take(6).toList(); // Max 6 photos

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive font size based on available width
        final containerWidth = constraints.maxWidth;
        final responsiveFontSize = (containerWidth * 0.035).clamp(14.0, 24.0);

        return Stack(
      children: [
        // Background surface
        Container(color: colorScheme.surface),

        // Decorative frame border (PNG image)
        Positioned.fill(
          child: Center(
            child: Image.asset(
              'assets/images/decorations/classic_boarder_olivebrown.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Content inside frame with padding to account for border
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top spacer (7% of page height)
              const Spacer(flex: 5),

              // Date at top center
              Center(
                child: Text(
                  dateFormatter.format(entry.eventDate),
                  style: GoogleFonts.justAnotherHand(
                    fontSize: responsiveFontSize * 1.5, // Same size as description
                    fontWeight: FontWeight.w400,
                    color: colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Spacer between date and photos (5% of page height)
              const Spacer(flex: 5),

              // Photo grid section - fills middle space (60% of page height)
              Expanded(
                flex: 60,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _buildPhotoGrid(photos),
                ),
              ),

              // Spacer between photos and text (5% of page height)
              const Spacer(flex: 5),

              // Text section - at bottom (centered with responsive width)
              FractionallySizedBox(
                widthFactor: 0.65, // 65% of available width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Highlight text
                    if (entry.highlightText.isNotEmpty)
                      Text(
                        entry.highlightText,
                        style: GoogleFonts.justAnotherHand(
                          fontSize: responsiveFontSize * 1.5, // Larger for handwritten font
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),

                    // Location
                    if (entry.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              entry.location!.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom spacer (4% of page height)
              const Spacer(flex: 4),
            ],
          ),
        ),
      ],
        );
      },
    );
  }

  Widget _buildPhotoGrid(List<Photo> photos) {
    // Scrapbook-style scattered Polaroid photos using Wrap
    // Densely packed for 5-6 photos to fill the page
    // Anchored to top-left to maximize visual coverage
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      children: photos.map((photo) {
        return PolaroidPhoto(
          photoUrl: photo.url,
          colorScheme: colorScheme,
          size: 190.0,
        );
      }).toList(),
    );
  }
}
