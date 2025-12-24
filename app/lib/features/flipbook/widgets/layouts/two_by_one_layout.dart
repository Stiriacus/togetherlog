// TogetherLog - 2×1 Layout Widget (Pixel-Perfect)
// Side-by-side layout for photo + location map
// Uses absolute positioning with exact pixel coordinates and random staggering

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/entry.dart';
import '../polaroid_photo.dart';
import '../polaroid_map.dart';
import '../layout_constants.dart';

/// 2×1 layout - displays photo and location map side by side
/// All elements positioned at exact pixel coordinates with staggered depth
class TwoByOneLayout extends StatelessWidget {
  const TwoByOneLayout({
    super.key,
    required this.entry,
    required this.colorScheme,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  /// Calculate staggered positions for photo and map
  /// Uses deterministic random based on entry ID + layoutVariant for consistency
  (Rect photoBox, Rect mapBox) _calculateStaggeredPositions() {
    // Use entry ID hash + layoutVariant for deterministic randomness
    final seed = entry.id.hashCode + entry.layoutVariant;
    final random = math.Random(seed);

    // Randomly choose which one goes up
    final photoGoesUp = random.nextBool();

    // Generate random offset between min and max (e.g., 120-175px)
    final offsetRange = LayoutConstants.twoByOneVerticalOffsetMax - LayoutConstants.twoByOneVerticalOffsetMin;
    final verticalOffset = LayoutConstants.twoByOneVerticalOffsetMin + (random.nextDouble() * offsetRange);

    final photoY = photoGoesUp
        ? LayoutConstants.twoByOnePhotoBoxBase.top - verticalOffset
        : LayoutConstants.twoByOnePhotoBoxBase.top;

    final mapY = photoGoesUp
        ? LayoutConstants.twoByOneMapBoxBase.top
        : LayoutConstants.twoByOneMapBoxBase.top - verticalOffset;

    final photoBox = Rect.fromLTWH(
      LayoutConstants.twoByOnePhotoBoxBase.left,
      photoY,
      LayoutConstants.twoByOnePhotoBoxBase.width,
      LayoutConstants.twoByOnePhotoBoxBase.height,
    );

    final mapBox = Rect.fromLTWH(
      LayoutConstants.twoByOneMapBoxBase.left,
      mapY,
      LayoutConstants.twoByOneMapBoxBase.width,
      LayoutConstants.twoByOneMapBoxBase.height,
    );

    return (photoBox, mapBox);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMMM d, yyyy');

    // Calculate staggered positions
    final (photoBox, mapBox) = _calculateStaggeredPositions();

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
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blue, width: 2),
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

        // PHOTO BOX (Left - with visible border for debugging, staggered)
        Positioned(
          left: photoBox.left,
          top: photoBox.top,
          width: photoBox.width,
          height: photoBox.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Center(
              child: entry.photos.isNotEmpty
                  ? PolaroidPhoto(
                      key: ValueKey('photo_${entry.photos.first.url}_${entry.layoutVariant}'),
                      photoUrl: entry.photos.first.url,
                      colorScheme: colorScheme,
                      size: LayoutConstants.polaroidSizeMedium,
                      layoutVariant: entry.layoutVariant,
                    )
                  : null,
            ),
          ),
        ),

        // MAP BOX (Right - with visible border for debugging, staggered)
        Positioned(
          left: mapBox.left,
          top: mapBox.top,
          width: mapBox.width,
          height: mapBox.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Center(
              child: entry.location != null
                  ? PolaroidMap(
                      key: ValueKey('map_${entry.location!.displayName}_${entry.layoutVariant}'),
                      location: entry.location!,
                      colorScheme: colorScheme,
                      size: LayoutConstants.polaroidSizeMedium,
                      layoutVariant: entry.layoutVariant,
                    )
                  : null,
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
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange, width: 2),
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
}
