// TogetherLog - Single Full Layout Widget (Pixel-Perfect)
// Hero layout for entries with 0-1 photos
// Uses absolute positioning with exact pixel coordinates

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';
import '../polaroid_map.dart';
import '../layout_constants.dart';

/// Single full layout - displays one large photo with text in a framed scrapbook page
/// All elements positioned at exact pixel coordinates
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

        // DATE BOX (with visible border for debugging)
        Positioned(
          left: LayoutConstants.dateBox.left,
          top: LayoutConstants.dateBox.top,
          width: LayoutConstants.dateBox.width,
          height: LayoutConstants.dateBox.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1), // Light blue background
              border: Border.all(color: Colors.blue, width: 2), // Blue border
            ),
            child: Center(
              child: Text(
                dateFormatter.format(entry.eventDate),
                style: GoogleFonts.justAnotherHand(
                  fontSize: LayoutConstants.dateFontSize,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        // CONTENT BOX (with visible border for debugging)
        Positioned(
          left: LayoutConstants.singleContentBox.left,
          top: LayoutConstants.singleContentBox.top,
          width: LayoutConstants.singleContentBox.width,
          height: LayoutConstants.singleContentBox.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1), // Light green background
              border: Border.all(color: Colors.green, width: 2), // Green border
            ),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),

        // TEXT BOX (with visible border for debugging)
        Positioned(
          left: LayoutConstants.textBox.left,
          top: LayoutConstants.textBox.top,
          width: LayoutConstants.textBox.width,
          height: LayoutConstants.textBox.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1), // Light orange background
              border: Border.all(color: Colors.orange, width: 2), // Orange border
            ),
            child: Center(
              child: entry.highlightText.isNotEmpty
                  ? Text(
                      entry.highlightText,
                      style: GoogleFonts.justAnotherHand(
                        fontSize: LayoutConstants.textFontSize,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: LayoutConstants.textLineHeight,
                      ),
                      maxLines: LayoutConstants.textMaxLines,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Build content (photo or map)
  Widget _buildContent() {
    final hasPhoto = entry.photos.isNotEmpty;
    final hasLocation = entry.location != null;

    // Only Photo
    if (hasPhoto) {
      return PolaroidPhoto(
        key: ValueKey('photo_${entry.photos.first.url}_${entry.layoutVariant}'),
        photoUrl: entry.photos.first.url,
        colorScheme: colorScheme,
        size: LayoutConstants.polaroidSizeLarge,
        layoutVariant: entry.layoutVariant,
      );
    }

    // Only Location
    if (hasLocation) {
      return PolaroidMap(
        key: ValueKey('map_${entry.location!.displayName}_${entry.layoutVariant}'),
        location: entry.location!,
        colorScheme: colorScheme,
        size: LayoutConstants.polaroidSizeLarge,
        layoutVariant: entry.layoutVariant,
      );
    }

    // No content
    return const SizedBox.shrink();
  }
}
