# Icon Placement System (Sprinkles)

**Created:** 2024-12-24
**Status:** Ready to Implement
**Priority:** Medium
**Effort:** Medium
**Dependencies:** `unified-coordinate-layout-system.md`

---

## Goal

Place decorative tag-based icons (sprinkles) at random coordinates on the page, ensuring they don't interfere with photos, maps, or text.

---

## Requirements

### Icon Specifications
- **Size:** 32px (fixed, scales with page)
- **Max count:** 3 icons per page
- **Rotation:** Random (-15° to +15°)
- **Selection:** Based on entry tags (already implemented in backend)
- **Collision:** Must NOT overlap with photos, maps, or text blocks

### Placement Strategy
1. Backend already computes which icons to show (sprinkles field in entry)
2. Client needs to compute WHERE to place them
3. Icons placed in "empty" areas between content
4. Deterministic: same entry = same icon positions

---

## Current Implementation

Icons are already selected by backend and stored in `entry.sprinkles` (list of icon names).

**File:** `app/lib/features/flipbook/widgets/sprinkles_overlay.dart` (already exists)

Need to enhance this to use coordinate-based collision detection.

---

## Enhanced Data Model

**Update:** `app/lib/features/flipbook/models/layout_data.dart`

```dart
/// Icon positioning data
@immutable
class IconLayoutData {
  final String iconName; // Material icon name
  final double x; // Pixels from left
  final double y; // Pixels from top
  final double rotation; // Rotation in degrees (-15 to +15)
  final double size; // Icon size (32px default)

  const IconLayoutData({
    required this.iconName,
    required this.x,
    required this.y,
    required this.rotation,
    this.size = 32.0,
  });

  /// Get bounding box for collision detection
  Rect get boundingBox => Rect.fromLTWH(x, y, size, size);
}
```

**Update PageLayoutData:**
```dart
class PageLayoutData {
  final List<ItemLayoutData> items; // Photos and maps
  final List<IconLayoutData> icons; // Decorative icons (NEW)
  final TextBlockLayout? textBlock;
  final double contentPadding;

  const PageLayoutData({
    required this.items,
    this.icons = const [], // NEW
    this.textBlock,
    this.contentPadding = 64.0,
  });
}
```

---

## Icon Placement Algorithm

**Update:** `app/lib/features/flipbook/services/layout_computer.dart`

```dart
/// Compute icon positions (called after items and text are positioned)
static List<IconLayoutData> _computeIconPositions({
  required List<String> sprinkles,
  required List<ItemLayoutData> items,
  required TextBlockLayout? textBlock,
}) {
  if (sprinkles.isEmpty) return [];

  final icons = <IconLayoutData>[];
  final occupiedRegions = <Rect>[];

  // Build list of occupied regions (photos, maps, text)
  for (final item in items) {
    occupiedRegions.add(_getItemBoundingBox(item));
  }

  if (textBlock != null) {
    occupiedRegions.add(Rect.fromLTWH(
      0,
      textBlock.y,
      PageConstants.contentWidth,
      100, // Approximate text height
    ));
  }

  // Place each icon
  for (int i = 0; i < sprinkles.length && i < 3; i++) {
    final iconData = _findIconPosition(
      iconName: sprinkles[i],
      index: i,
      occupiedRegions: occupiedRegions,
    );

    if (iconData != null) {
      icons.add(iconData);
      occupiedRegions.add(iconData.boundingBox);
    }
  }

  return icons;
}

/// Get bounding box for an item (with padding for safety)
static Rect _getItemBoundingBox(ItemLayoutData item) {
  const padding = 16.0; // Safety margin around items

  return Rect.fromLTWH(
    item.x - padding,
    item.y - padding,
    item.width + (padding * 2),
    item.height + (padding * 2),
  );
}

/// Find valid position for an icon
/// Returns null if no valid position found after max attempts
static IconLayoutData? _findIconPosition({
  required String iconName,
  required int index,
  required List<Rect> occupiedRegions,
}) {
  const iconSize = 32.0;
  const maxAttempts = 20;

  // Use icon name + index for deterministic randomness
  final random = math.Random('${iconName}_$index'.hashCode);

  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    // Generate random position within content area
    final x = random.nextDouble() * (PageConstants.contentWidth - iconSize);
    final y = random.nextDouble() * (PageConstants.contentHeight - iconSize);

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
```

---

## Updated LayoutComputer.computeLayout()

```dart
static PageLayoutData computeLayout(Entry entry) {
  final photos = entry.photos;
  final hasLocation = entry.location != null;
  final photoCount = photos.length;
  final mapCount = hasLocation ? 1 : 0;
  final totalItems = photoCount + mapCount;

  if (totalItems > PageConstants.maxPhotosAndMaps) {
    throw Exception('Too many items: $totalItems (max ${PageConstants.maxPhotosAndMaps})');
  }

  // Compute item layouts
  final items = _computeItemPositions(
    photos: photos,
    hasLocation: hasLocation,
    totalItems: totalItems,
  );

  // Compute text block position
  final textBlock = _computeTextBlock(items);

  // Compute icon positions (NEW)
  final icons = _computeIconPositions(
    sprinkles: entry.sprinkles,
    items: items,
    textBlock: textBlock,
  );

  return PageLayoutData(
    items: items,
    icons: icons, // NEW
    textBlock: textBlock,
    contentPadding: PageConstants.horizontalPadding,
  );
}
```

---

## Icon Rendering

**Update:** `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart`

```dart
@override
Widget build(BuildContext context) {
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

      // Content area
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PageConstants.horizontalPadding,
          vertical: PageConstants.verticalPadding,
        ),
        child: Stack(
          children: [
            // Render icons (BEHIND photos/maps)
            ...layoutData.icons.map((icon) => _buildIcon(icon)),

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

Widget _buildIcon(IconLayoutData iconData) {
  return Positioned(
    left: iconData.x,
    top: iconData.y,
    child: Transform.rotate(
      angle: iconData.rotation * (math.pi / 180),
      child: Icon(
        _getIconFromName(iconData.iconName),
        size: iconData.size,
        color: colorScheme.primary.withValues(alpha: 0.3), // Semi-transparent
      ),
    ),
  );
}

IconData _getIconFromName(String iconName) {
  // Map sprinkle names to Material icons
  switch (iconName) {
    case 'favorite':
      return Icons.favorite;
    case 'star':
      return Icons.star;
    case 'local_florist':
      return Icons.local_florist;
    case 'cake':
      return Icons.cake;
    case 'beach_access':
      return Icons.beach_access;
    // ... add more mappings based on backend sprinkle names
    default:
      return Icons.star;
  }
}
```

---

## Icon Layering Strategy

**Z-index order (bottom to top):**
1. Background color
2. Decorative frame image
3. **Icons (semi-transparent, behind content)**
4. Photos and maps
5. Text block

**Rationale:** Icons are decorative and should not compete with actual content.

---

## Alternative: Icons in Front

If icons should appear **in front** of photos (like stickers), change stack order:

```dart
Stack(
  children: [
    // ... background, frame, content padding ...
    Stack(
      children: [
        // Render items FIRST
        ...layoutData.items.map((item) => _buildItem(item)),

        // Render icons ON TOP
        ...layoutData.icons.map((icon) => _buildIcon(icon)),

        // Text always on top
        if (layoutData.textBlock != null && entry.highlightText.isNotEmpty)
          _buildTextBlock(layoutData.textBlock!, entry.highlightText),
      ],
    ),
  ],
);
```

**Question for user:** Should icons appear behind or in front of photos?

---

## Testing Checklist

- [ ] Update `layout_data.dart` with `IconLayoutData` model
- [ ] Implement `_computeIconPositions()` in `LayoutComputer`
- [ ] Implement collision detection with items and text
- [ ] Test with 0 icons (empty sprinkles array)
- [ ] Test with 1 icon
- [ ] Test with 2 icons
- [ ] Test with 3 icons
- [ ] Test with 3+ icons (should only place 3)
- [ ] Verify icons don't overlap with photos
- [ ] Verify icons don't overlap with maps
- [ ] Verify icons don't overlap with text
- [ ] Verify icons stay within content bounds
- [ ] Verify rotations are random but deterministic
- [ ] Test with page full of 4 photos (icons should find gaps)
- [ ] Test with page with only text (icons should scatter)

---

## Benefits

✅ **Collision Detection** — Icons never interfere with content
✅ **Deterministic Placement** — Same entry = same icon positions
✅ **Scrapbook Aesthetic** — Random rotations feel hand-placed
✅ **Backend Integration** — Works with existing sprinkles system
✅ **Configurable Layering** — Icons can go behind or in front of photos
