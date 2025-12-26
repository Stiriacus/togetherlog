# Client-Side Layout Computation Service

**Created:** 2024-12-24
**Status:** Ready to Implement
**Priority:** High
**Effort:** Medium
**Dependencies:** `page-dimensions-content-box.md`

---

## Goal

Create a centralized service for computing exact photo and location map coordinates using absolute positioning (not grids).

**⚠️ ARCHITECTURAL NOTE:** This is a temporary CLIENT-SIDE implementation for rapid testing. Will be migrated to backend in V2.

---

## Core Principles

1. **Max 4 Items Total:** Photos + Location Maps combined cannot exceed 4
   - Example: 3 photos + 1 map = 4 total ✅
   - Example: 4 photos + 0 maps = 4 total ✅
   - Example: 2 photos + 2 maps = 4 total (future enhancement)

2. **Coordinate-Based:** Every item gets exact (x, y, width, height, rotation)
   - No grids, no Wrap widgets, no automatic layout
   - Absolute positioning using Stack + Positioned

3. **Orientation-Aware:** Photo/map sizing considers aspect ratio
   - Portrait: taller than wide (e.g., 220x280)
   - Landscape: wider than tall (e.g., 280x220)
   - Square: equal dimensions (e.g., 240x240)

4. **Deterministic Rotation:** Same photo ID = same rotation angle
   - Range: -5° to +5°
   - Seeded by photo/location ID hash

---

## Data Models

**New file:** `app/lib/features/flipbook/models/layout_data.dart`

```dart
import 'package:flutter/foundation.dart';

/// Represents exact positioning data for a photo or location map
@immutable
class ItemLayoutData {
  final String itemId; // Photo ID or "location"
  final ItemType type; // photo or map
  final double x; // Pixels from left edge
  final double y; // Pixels from top edge
  final double width; // Polaroid width
  final double height; // Polaroid height (excluding caption)
  final double rotation; // Rotation in degrees (-5 to +5)

  const ItemLayoutData({
    required this.itemId,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
  });
}

enum ItemType {
  photo,
  map,
}

/// Complete layout data for a page
@immutable
class PageLayoutData {
  final List<ItemLayoutData> items; // Photos and maps
  final TextBlockLayout? textBlock;
  final double contentPadding; // Padding from frame edge

  const PageLayoutData({
    required this.items,
    this.textBlock,
    this.contentPadding = 64.0,
  });

  int get photoCount => items.where((i) => i.type == ItemType.photo).length;
  int get mapCount => items.where((i) => i.type == ItemType.map).length;
  int get totalItems => items.length;
}

/// Text block positioning
@immutable
class TextBlockLayout {
  final double y; // Y position (top edge)
  final double maxWidth; // Maximum text width

  const TextBlockLayout({
    required this.y,
    required this.maxWidth,
  });
}
```

---

## Service Implementation

**New file:** `app/lib/features/flipbook/services/layout_computer.dart`

```dart
import 'dart:math' as math;
import '../models/layout_data.dart';
import '../constants/page_constants.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/photo.dart';

/// Client-side layout computation service
/// Computes exact coordinates for photos and location maps
class LayoutComputer {
  LayoutComputer._(); // Private constructor - static class only

  /// Compute layout for an entry
  /// Handles 0-4 items (photos + location map)
  static PageLayoutData computeLayout(Entry entry) {
    final photos = entry.photos;
    final hasLocation = entry.location != null;

    // Count total items (photos + map)
    final photoCount = photos.length;
    final mapCount = hasLocation ? 1 : 0;
    final totalItems = photoCount + mapCount;

    // Enforce max 4 items
    if (totalItems > PageConstants.maxPhotosAndMaps) {
      throw Exception('Too many items: $totalItems (max ${PageConstants.maxPhotosAndMaps})');
    }

    // Compute item layouts based on total count
    final items = _computeItemPositions(
      photos: photos,
      hasLocation: hasLocation,
      totalItems: totalItems,
    );

    // Compute text block position (below items)
    final textBlock = _computeTextBlock(items);

    return PageLayoutData(
      items: items,
      textBlock: textBlock,
      contentPadding: PageConstants.horizontalPadding,
    );
  }

  /// Compute positions for all items (photos + map)
  static List<ItemLayoutData> _computeItemPositions({
    required List<Photo> photos,
    required bool hasLocation,
    required int totalItems,
  }) {
    final items = <ItemLayoutData>[];

    // Define base sizes based on item count
    final baseSize = _getBaseSizeForItemCount(totalItems);

    // Create layout data for photos
    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final position = _getPositionForIndex(i, totalItems);

      items.add(ItemLayoutData(
        itemId: photo.id,
        type: ItemType.photo,
        x: position.x,
        y: position.y,
        width: baseSize,
        height: baseSize * 1.15, // Polaroid aspect ratio (square photo + caption)
        rotation: _generateRotation(photo.id),
      ));
    }

    // Create layout data for location map (if present)
    if (hasLocation) {
      final position = _getPositionForIndex(photos.length, totalItems);

      items.add(ItemLayoutData(
        itemId: 'location',
        type: ItemType.map,
        x: position.x,
        y: position.y,
        width: baseSize,
        height: baseSize * 1.15, // Same aspect as photo Polaroid
        rotation: _generateRotation('location_${totalItems}'),
      ));
    }

    return items;
  }

  /// Get base Polaroid size based on total item count
  static double _getBaseSizeForItemCount(int count) {
    switch (count) {
      case 0:
        return 0; // No items
      case 1:
        return 320.0; // Large single item
      case 2:
        return 260.0; // Two medium items
      case 3:
        return 220.0; // Three smaller items
      case 4:
        return 190.0; // Four small items
      default:
        return 190.0; // Fallback to smallest
    }
  }

  /// Get (x, y) position for item at given index
  /// Returns coordinates within content area (0,0 = top-left of usable space)
  static ({double x, double y}) _getPositionForIndex(int index, int totalItems) {
    final contentWidth = PageConstants.contentWidth;
    final contentHeight = PageConstants.contentHeight;
    final baseSize = _getBaseSizeForItemCount(totalItems);
    final polaroidHeight = baseSize * 1.15;

    switch (totalItems) {
      case 1:
        // Single item: centered
        return (
          x: (contentWidth - baseSize) / 2,
          y: contentHeight * 0.15, // 15% from top
        );

      case 2:
        // Two items: horizontal row, centered
        final spacing = 32.0;
        final totalWidth = (baseSize * 2) + spacing;
        final startX = (contentWidth - totalWidth) / 2;

        return (
          x: startX + (index * (baseSize + spacing)),
          y: contentHeight * 0.15,
        );

      case 3:
        // Three items: 2 on top row, 1 centered on bottom
        if (index < 2) {
          // Top row
          final spacing = 32.0;
          final totalWidth = (baseSize * 2) + spacing;
          final startX = (contentWidth - totalWidth) / 2;

          return (
            x: startX + (index * (baseSize + spacing)),
            y: contentHeight * 0.1,
          );
        } else {
          // Bottom row (centered)
          return (
            x: (contentWidth - baseSize) / 2,
            y: contentHeight * 0.1 + polaroidHeight + 24,
          );
        }

      case 4:
        // Four items: 2x2 grid, centered
        final spacing = 24.0;
        final totalWidth = (baseSize * 2) + spacing;
        final totalHeight = (polaroidHeight * 2) + spacing;
        final startX = (contentWidth - totalWidth) / 2;
        final startY = contentHeight * 0.08;

        final row = index ~/ 2; // 0 or 1
        final col = index % 2;  // 0 or 1

        return (
          x: startX + (col * (baseSize + spacing)),
          y: startY + (row * (polaroidHeight + spacing)),
        );

      default:
        // Fallback: top-left corner
        return (x: 0.0, y: 0.0);
    }
  }

  /// Generate deterministic rotation angle from item ID
  /// Same ID = same rotation (stable across rebuilds)
  static double _generateRotation(String itemId) {
    final hash = itemId.hashCode.abs();
    final normalized = (hash % 1000) / 1000.0; // 0.0 to 1.0
    return (normalized * 10.0) - 5.0; // -5.0 to +5.0 degrees
  }

  /// Compute text block position (below items)
  static TextBlockLayout _computeTextBlock(List<ItemLayoutData> items) {
    if (items.isEmpty) {
      // No items: text starts at 20% of page height
      return TextBlockLayout(
        y: PageConstants.contentHeight * 0.2,
        maxWidth: PageConstants.contentWidth * 0.8, // 80% of content width
      );
    }

    // Find lowest point of all items (y + height)
    double lowestPoint = 0;
    for (final item in items) {
      final itemBottom = item.y + item.height;
      if (itemBottom > lowestPoint) {
        lowestPoint = itemBottom;
      }
    }

    // Text starts 48px below lowest item
    return TextBlockLayout(
      y: lowestPoint + 48,
      maxWidth: PageConstants.contentWidth * 0.8,
    );
  }
}
```

---

## Integration Example

**File:** `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart` (new unified layout)

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/layout_computer.dart';
import '../../models/layout_data.dart';
import '../../constants/page_constants.dart';
import '../polaroid_photo.dart';
import '../polaroid_map.dart';
import '../../../../data/models/entry.dart';

/// Unified coordinate-based layout renderer
/// Replaces single_full, grid_2x2, grid_3x2 layouts
class CoordinateLayout extends StatelessWidget {
  const CoordinateLayout({
    required this.entry,
    required this.colorScheme,
    super.key,
  });

  final Entry entry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // Compute layout
    final layoutData = LayoutComputer.computeLayout(entry);

    return Stack(
      children: [
        // Background
        Container(color: colorScheme.surface),

        // Decorative frame
        Positioned.fill(
          child: Image.asset(
            'assets/images/decorations/classic_boarder_olivebrown.png',
            fit: BoxFit.contain,
          ),
        ),

        // Content area (with padding for frame)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PageConstants.horizontalPadding,
            vertical: PageConstants.verticalPadding,
          ),
          child: Stack(
            children: [
              // Render items (photos and maps)
              ...layoutData.items.map((item) => _buildItem(item)),

              // Render text block
              if (layoutData.textBlock != null && entry.highlightText.isNotEmpty)
                _buildTextBlock(layoutData.textBlock!, entry.highlightText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(ItemLayoutData item) {
    return Positioned(
      left: item.x,
      top: item.y,
      child: Transform.rotate(
        angle: item.rotation * (math.pi / 180),
        child: item.type == ItemType.photo
            ? _buildPhoto(item)
            : _buildMap(item),
      ),
    );
  }

  Widget _buildPhoto(ItemLayoutData item) {
    final photo = entry.photos.firstWhere((p) => p.id == item.itemId);

    return PolaroidPhoto(
      photoUrl: photo.url,
      colorScheme: colorScheme,
      size: item.width,
    );
  }

  Widget _buildMap(ItemLayoutData item) {
    return PolaroidMap(
      location: entry.location!,
      colorScheme: colorScheme,
      size: item.width,
    );
  }

  Widget _buildTextBlock(TextBlockLayout textBlock, String text) {
    return Positioned(
      top: textBlock.y,
      left: (PageConstants.contentWidth - textBlock.maxWidth) / 2,
      child: SizedBox(
        width: textBlock.maxWidth,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: colorScheme.onSurface,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
```

---

## Testing Checklist

- [ ] Create `layout_data.dart` models
- [ ] Create `layout_computer.dart` service
- [ ] Implement `computeLayout()` function
- [ ] Test with 0 items (text only)
- [ ] Test with 1 photo
- [ ] Test with 1 location map
- [ ] Test with 2 photos
- [ ] Test with 1 photo + 1 map
- [ ] Test with 3 photos
- [ ] Test with 2 photos + 1 map
- [ ] Test with 4 photos
- [ ] Test with 3 photos + 1 map
- [ ] Verify rotations are deterministic (same ID = same angle)
- [ ] Verify items don't overlap
- [ ] Verify items fit within content bounds
- [ ] Verify text doesn't overlap items

---

## Benefits

✅ **Absolute Control** — Exact positioning, no automatic layout surprises
✅ **Scalable** — Works with 0-4 items consistently
✅ **Location Support** — Maps count as items in layout
✅ **Deterministic** — Same content = same layout every time
✅ **Backend Migration Ready** — Data structure matches future backend JSONB schema
