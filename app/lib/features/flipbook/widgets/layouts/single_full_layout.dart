// TogetherLog - Single Full Layout Widget
// Hero layout for entries with 0-1 photos
// Scrapbook-style with Polaroid photo and decorative frame

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';
import '../polaroid_map.dart';

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
    final dateFormatter = DateFormat('MMMM d, yyyy');

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

              // Spacer between date and photo (5% of page height)
              const Spacer(flex: 5),

              // Photo/Map section - fills middle space (60% of page height)
              Expanded(
                flex: 60,
                child: Center(
                  child: _buildContentGrid(),
                ),
              ),

              // Spacer between photo and text (5% of page height)
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
                  ],
                ),
              ),

              // Bottom spacer (6% of page height)
              const Spacer(flex: 4),
            ],
          ),
        ),
      ],
        );
      },
    );
  }

  /// Build content grid with photo(s) and map
  Widget _buildContentGrid() {
    final hasPhoto = entry.photos.isNotEmpty;
    final hasLocation = entry.location != null;

    // Case 1: Photo + Location → Show both in a row
    if (hasPhoto && hasLocation) {
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          PolaroidPhoto(
            photoUrl: entry.photos.first.url,
            colorScheme: colorScheme,
            size: 280.0,
          ),
          PolaroidMap(
            location: entry.location!,
            colorScheme: colorScheme,
            size: 280.0,
          ),
        ],
      );
    }

    // Case 2: Only Photo
    if (hasPhoto) {
      return PolaroidPhoto(
        photoUrl: entry.photos.first.url,
        colorScheme: colorScheme,
        size: 380.0,
      );
    }

    // Case 3: Only Location
    if (hasLocation) {
      return PolaroidMap(
        location: entry.location!,
        colorScheme: colorScheme,
        size: 380.0,
      );
    }

    // Case 4: No photo, no location
    return const SizedBox.shrink();
  }
}
