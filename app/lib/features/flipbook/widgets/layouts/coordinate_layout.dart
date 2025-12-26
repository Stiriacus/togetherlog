// TogetherLog - Unified Coordinate Layout Widget
// Single layout renderer for all item counts (0-4 items)
// Replaces SingleFullLayout and TwoByOneLayout

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../../data/models/entry.dart';
import '../../models/layout_data.dart';
import '../../services/layout_computer.dart';
import '../polaroid_photo.dart';
import '../polaroid_map.dart';
import '../layout_constants.dart';

/// Unified coordinate-based layout for all flipbook pages
/// Handles 0-4 items (any combination of photos and maps)
class CoordinateLayout extends StatelessWidget {
  const CoordinateLayout({
    super.key,
    required this.entry,
    required this.colorScheme,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMMM d, yyyy');

    // Compute layout coordinates
    final layoutData = LayoutComputer.computeLayout(entry);

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

        // DATE BOX (fixed position)
        Positioned(
          left: LayoutConstants.dateBox.left,
          top: LayoutConstants.dateBox.top,
          width: LayoutConstants.dateBox.width,
          height: LayoutConstants.dateBox.height,
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

        // CONTENT AREA (photos, maps, icons)
        Positioned(
          left: LayoutConstants.framePaddingHorizontal,
          top: LayoutConstants.framePaddingVertical,
          width: LayoutConstants.contentAreaWidth,
          height: LayoutConstants.contentAreaHeight,
          child: Stack(
            children: [
              // Render icons (z-index: -1, behind photos)
              ...layoutData.iconsByZIndex.map((icon) => _buildIcon(icon)),

              // Render items (photos and maps, z-index: 0+)
              ...layoutData.itemsByZIndex.map((item) => _buildItem(item)),
            ],
          ),
        ),

        // TEXT BOX (fixed position)
        if (layoutData.textBlock != null && entry.highlightText.isNotEmpty)
          Positioned(
            left: LayoutConstants.textBox.left,
            top: LayoutConstants.textBox.top,
            width: LayoutConstants.textBox.width,
            height: LayoutConstants.textBox.height,
            child: Center(
              child: Text(
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
              ),
            ),
          ),
      ],
    );
  }

  /// Build a positioned item (photo or map) with rotation
  Widget _buildItem(ItemLayoutData item) {
    return Positioned(
      left: item.x,
      top: item.y,
      child: Transform.rotate(
        angle: item.rotation * (math.pi / 180), // Convert degrees to radians
        child: _buildItemContent(item),
      ),
    );
  }

  /// Build the actual item content (polaroid photo or map)
  Widget _buildItemContent(ItemLayoutData item) {
    if (item.type == ItemType.photo) {
      // Find the corresponding photo from entry
      final photoIndex = int.tryParse(item.itemId.replaceAll('photo_', '')) ?? 0;
      if (photoIndex < entry.photos.length) {
        final photo = entry.photos[photoIndex];
        return PolaroidPhoto(
          key: ValueKey('photo_${photo.url}_${entry.layoutVariant}'),
          photoUrl: photo.url,
          colorScheme: colorScheme,
          size: item.width,
          layoutVariant: entry.layoutVariant,
        );
      }
    } else if (item.type == ItemType.map && entry.location != null) {
      return PolaroidMap(
        key: ValueKey('map_${entry.location!.displayName}_${entry.layoutVariant}'),
        location: entry.location!,
        colorScheme: colorScheme,
        size: item.width,
        layoutVariant: entry.layoutVariant,
      );
    }

    // Fallback for invalid items
    return const SizedBox.shrink();
  }

  /// Build a positioned icon (decorative sprinkle)
  Widget _buildIcon(IconLayoutData icon) {
    return Positioned(
      left: icon.x,
      top: icon.y,
      child: Transform.rotate(
        angle: icon.rotation * (math.pi / 180),
        child: Icon(
          _getIconFromName(icon.iconName),
          size: icon.size,
          color: colorScheme.primary.withValues(alpha: 0.3), // Semi-transparent
        ),
      ),
    );
  }

  /// Map icon name to Material icon
  /// TODO: Move to separate icon mapping service
  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'favorite':
      case 'heart':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'local_florist':
      case 'flower':
        return Icons.local_florist;
      case 'cake':
        return Icons.cake;
      case 'beach_access':
      case 'beach':
        return Icons.beach_access;
      case 'terrain':
      case 'mountain':
        return Icons.terrain;
      case 'flight':
      case 'airplane':
        return Icons.flight;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard;
      case 'celebration':
      case 'balloon':
        return Icons.celebration;
      default:
        return Icons.star;
    }
  }
}
