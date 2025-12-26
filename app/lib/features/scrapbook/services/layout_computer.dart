// TogetherLog - Layout Computer Service
// Calculates exact pixel coordinates for all page elements
// Supports 0-4 items (photos + location maps) with deterministic positioning

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../../../../data/models/entry.dart';
import '../models/layout_data.dart';
import '../widgets/layout_constants.dart';

/// Service for computing page layout coordinates
/// Generates deterministic positions based on entry content and layoutVariant
class LayoutComputer {
  LayoutComputer._(); // Private constructor - static class only

  /// Compute complete page layout for an entry
  /// Returns PageLayoutData with all positioned elements
  static PageLayoutData computeLayout(Entry entry) {
    final photos = entry.photos;
    final hasLocation = entry.location != null;
    final photoCount = photos.length;
    final mapCount = hasLocation ? 1 : 0;
    final totalItems = photoCount + mapCount;

    // Enforce max items constraint
    if (totalItems > LayoutConstants.maxPhotosAndMaps) {
      debugPrint(
          'Warning: Entry has $totalItems items (max ${LayoutConstants.maxPhotosAndMaps}). Only first ${LayoutConstants.maxPhotosAndMaps} will be displayed.',);
    }

    // Compute item positions
    final items = _computeItemPositions(
      photos: photos,
      hasLocation: hasLocation,
      totalItems: totalItems.clamp(0, LayoutConstants.maxPhotosAndMaps),
      layoutVariant: entry.layoutVariant,
    );

    // Compute text block position (uses fixed constants for now)
    final textBlock = entry.highlightText.isNotEmpty
        ? TextBlockLayout(
            y: LayoutConstants.textBox.top,
            maxWidth: LayoutConstants.textBox.width,
          )
        : null;

    // Compute icon positions with collision detection
    final icons = _computeIconPositions(
      sprinkles: entry.sprinkles ?? [],
      items: items,
      textBlock: textBlock,
      layoutVariant: entry.layoutVariant,
    );

    return PageLayoutData(
      items: items,
      icons: icons,
      textBlock: textBlock,
    );
  }

  /// Compute positions for all items (photos and maps)
  static List<ItemLayoutData> _computeItemPositions({
    required List<dynamic> photos,
    required bool hasLocation,
    required int totalItems,
    required int layoutVariant,
  }) {
    final items = <ItemLayoutData>[];

    if (totalItems == 0) {
      return items; // No items to position
    }

    // Determine polaroid size based on item count
    final polaroidSize = _getPolaroidSize(totalItems);

    // Add photos
    for (int i = 0; i < photos.length && items.length < totalItems; i++) {
      final position = _getPositionForIndex(
        index: items.length,
        totalItems: totalItems,
        polaroidSize: polaroidSize,
        layoutVariant: layoutVariant,
      );

      items.add(ItemLayoutData(
        itemId: 'photo_$i',
        type: ItemType.photo,
        x: position['x']!,
        y: position['y']!,
        width: polaroidSize,
        height: _getPolaroidHeight(polaroidSize),
        rotation: position['rotation']!,
        zIndex: 0,
      ),);
    }

    // Add location map if present
    if (hasLocation && items.length < totalItems) {
      final position = _getPositionForIndex(
        index: items.length,
        totalItems: totalItems,
        polaroidSize: polaroidSize,
        layoutVariant: layoutVariant,
      );

      items.add(ItemLayoutData(
        itemId: 'location',
        type: ItemType.map,
        x: position['x']!,
        y: position['y']!,
        width: polaroidSize,
        height: _getPolaroidHeight(polaroidSize),
        rotation: position['rotation']!,
        zIndex: 0,
      ),);
    }

    return items;
  }

  /// Get position for item at specific index
  /// Returns map with x, y, and rotation values
  static Map<String, double> _getPositionForIndex({
    required int index,
    required int totalItems,
    required double polaroidSize,
    required int layoutVariant,
  }) {
    switch (totalItems) {
      case 1:
        return _getSingleItemPosition(polaroidSize, layoutVariant);
      case 2:
        return _getTwoItemPosition(index, polaroidSize, layoutVariant);
      case 3:
        return _getThreeItemPosition(index, polaroidSize, layoutVariant);
      case 4:
        return _getFourItemPosition(index, polaroidSize, layoutVariant);
      default:
        return {'x': 0.0, 'y': 0.0, 'rotation': 0.0};
    }
  }

  /// Single item: Large, centered
  static Map<String, double> _getSingleItemPosition(
    double polaroidSize,
    int layoutVariant,
  ) {
    // Center horizontally within content area
    final x = (LayoutConstants.contentAreaWidth - polaroidSize) / 2;
    // Position from top of content box
    final y = LayoutConstants.singleContentBox.top - LayoutConstants.framePaddingVertical;

    return {
      'x': x,
      'y': y,
      'rotation': _generateRotation('single_0', layoutVariant),
    };
  }

  /// Two items: Side-by-side with staggering
  static Map<String, double> _getTwoItemPosition(
    int index,
    double polaroidSize,
    int layoutVariant,
  ) {
    // Use existing base positions from LayoutConstants
    final baseX = index == 0
        ? LayoutConstants.twoByOnePhotoBoxBase.left
        : LayoutConstants.twoByOneMapBoxBase.left;

    final baseY = LayoutConstants.twoByOnePhotoBoxBase.top;

    // Apply vertical staggering to one item (deterministic)
    final random = math.Random('two_item_$layoutVariant'.hashCode);
    final staggerIndex = random.nextInt(2); // Which item to stagger (0 or 1)
    final staggerAmount = LayoutConstants.twoByOneVerticalOffsetMin +
        random.nextDouble() *
            (LayoutConstants.twoByOneVerticalOffsetMax -
                LayoutConstants.twoByOneVerticalOffsetMin);

    final y = index == staggerIndex
        ? baseY - staggerAmount // Move up
        : baseY;

    // Adjust for frame padding
    final adjustedY = y - LayoutConstants.framePaddingVertical;

    return {
      'x': baseX - LayoutConstants.framePaddingHorizontal,
      'y': adjustedY,
      'rotation': _generateRotation('two_$index', layoutVariant),
    };
  }

  /// Three items: 2 top row + 1 bottom centered
  static Map<String, double> _getThreeItemPosition(
    int index,
    double polaroidSize,
    int layoutVariant,
  ) {
    const gap = LayoutConstants.itemSpacingThreeItems;
    const contentWidth = LayoutConstants.contentAreaWidth;

    if (index < 2) {
      // Top row (2 items)
      final totalWidthTopRow = (polaroidSize * 2) + gap;
      final startX = (contentWidth - totalWidthTopRow) / 2;
      final x = startX + (index * (polaroidSize + gap));
      const y = 100.0; // From top of content area

      return {
        'x': x,
        'y': y,
        'rotation': _generateRotation('three_$index', layoutVariant),
      };
    } else {
      // Bottom item (centered)
      final x = (contentWidth - polaroidSize) / 2;
      final y = 100.0 + _getPolaroidHeight(polaroidSize) + 40.0; // Below top row

      return {
        'x': x,
        'y': y,
        'rotation': _generateRotation('three_$index', layoutVariant),
      };
    }
  }

  /// Four items: 2×2 grid with staggering
  static Map<String, double> _getFourItemPosition(
    int index,
    double polaroidSize,
    int layoutVariant,
  ) {
    const gap = LayoutConstants.itemSpacingFourItems;
    const contentWidth = LayoutConstants.contentAreaWidth;
    final polaroidHeight = _getPolaroidHeight(polaroidSize);

    // Calculate grid positions
    final totalWidth = (polaroidSize * 2) + gap;
    final startX = (contentWidth - totalWidth) / 2;

    final row = index ~/ 2; // 0 or 1
    final col = index % 2;  // 0 or 1

    final x = startX + (col * (polaroidSize + gap));
    final baseY = 60.0 + (row * (polaroidHeight + gap));

    // Add small random stagger for depth
    final random = math.Random('four_${index}_$layoutVariant'.hashCode);
    final staggerY = random.nextDouble() * 40.0 - 20.0; // -20 to +20

    return {
      'x': x,
      'y': baseY + staggerY,
      'rotation': _generateRotation('four_$index', layoutVariant),
    };
  }

  /// Get polaroid size based on number of items
  static double _getPolaroidSize(int itemCount) {
    switch (itemCount) {
      case 0:
      case 1:
        return LayoutConstants.polaroidSizeLarge; // 420px
      case 2:
        return LayoutConstants.polaroidSizeMedium; // 340px
      case 3:
        return LayoutConstants.polaroidSizeSmall; // 280px (planned)
      case 4:
        return LayoutConstants.polaroidSizeXSmall; // 220px (planned)
      default:
        return LayoutConstants.polaroidSizeMedium;
    }
  }

  /// Calculate polaroid height (width + caption space)
  /// Polaroids have ~1.15 aspect ratio (square photo + caption)
  static double _getPolaroidHeight(double width) {
    return width * 1.15;
  }

  /// Generate deterministic rotation angle
  /// Uses item ID and layout variant for consistent randomness
  static double _generateRotation(String itemId, int layoutVariant) {
    final random = math.Random('${itemId}_$layoutVariant'.hashCode);
    final rotation = LayoutConstants.minRotation +
        random.nextDouble() *
            (LayoutConstants.maxRotation - LayoutConstants.minRotation);
    return rotation;
  }

  /// Compute icon positions with collision detection
  /// Returns list of positioned icons (max 3)
  static List<IconLayoutData> _computeIconPositions({
    required List<String> sprinkles,
    required List<ItemLayoutData> items,
    required TextBlockLayout? textBlock,
    required int layoutVariant,
  }) {
    if (sprinkles.isEmpty) return [];

    final icons = <IconLayoutData>[];
    final occupiedRegions = <Rect>[];

    // Build list of occupied regions (photos, maps, text)
    for (final item in items) {
      occupiedRegions.add(_getItemBoundingBox(item));
    }

    // Add text block region if present
    if (textBlock != null) {
      occupiedRegions.add(Rect.fromLTWH(
        0,
        textBlock.y,
        LayoutConstants.contentAreaWidth,
        100, // Approximate text height
      ),);
    }

    // Place each icon (max 3)
    for (int i = 0; i < sprinkles.length && i < 3; i++) {
      final iconData = _findIconPosition(
        iconName: sprinkles[i],
        index: i,
        occupiedRegions: occupiedRegions,
        layoutVariant: layoutVariant,
      );

      if (iconData != null) {
        icons.add(iconData);
        occupiedRegions.add(iconData.boundingBox);
      }
    }

    return icons;
  }

  /// Get bounding box for an item with safety padding
  static Rect _getItemBoundingBox(ItemLayoutData item) {
    const padding = 16.0; // Safety margin around items

    return Rect.fromLTWH(
      item.x - padding,
      item.y - padding,
      item.width + (padding * 2),
      item.height + (padding * 2),
    );
  }

  /// Find valid position for an icon with collision detection
  /// Returns null if no valid position found after max attempts
  static IconLayoutData? _findIconPosition({
    required String iconName,
    required int index,
    required List<Rect> occupiedRegions,
    required int layoutVariant,
  }) {
    const iconSize = 32.0;
    const maxAttempts = 20;

    // Use icon name + index + layoutVariant for deterministic randomness
    final random = math.Random('${iconName}_${index}_$layoutVariant'.hashCode);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // Generate random position within content area
      final x = random.nextDouble() * (LayoutConstants.contentAreaWidth - iconSize);
      final y = random.nextDouble() * (LayoutConstants.contentAreaHeight - iconSize);

      final iconRect = Rect.fromLTWH(x, y, iconSize, iconSize);

      // Check collision with all occupied regions
      bool hasCollision = false;
      for (final region in occupiedRegions) {
        if (iconRect.overlaps(region)) {
          hasCollision = true;
          break;
        }
      }

      // Valid position found
      if (!hasCollision) {
        final rotation = -15.0 + (random.nextDouble() * 30.0); // -15 to +15

        return IconLayoutData(
          iconName: iconName,
          x: x,
          y: y,
          rotation: rotation,
          size: iconSize,
        );
      }
    }

    // No valid position found after max attempts
    return null;
  }
}
