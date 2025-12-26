# Unified Coordinate-Based Layout System

**Created:** 2025-12-26
**Status:** Planning
**Priority:** Medium
**Effort:** High
**Dependencies:** `layout_constants.dart`, existing layout widgets

---

## Goal

Replace the current layout-specific widgets (`SingleFullLayout`, `TwoByOneLayout`) with a **unified coordinate-based layout system** that handles 0-4 items (photos + location maps) using absolute positioning.

This system will:
- Support any combination of photos and maps (max 4 total items)
- Use deterministic positioning with seeded randomness for variation
- Apply rotation and staggering to all items
- Handle 3-item layouts (2 top, 1 bottom centered)
- Provide a single rendering path for all page types

---

## Current State

**Layout Widgets:**
- `SingleFullLayout` - Handles 1 photo OR 1 location map
- `TwoByOneLayout` - Handles 1 photo + 1 location map (side-by-side with staggering)

**Limitations:**
- No support for 2 photos without location
- No support for 3 items (any combination)
- No support for 4 items
- Each layout type requires separate widget implementation
- Inconsistent staggering/rotation logic across layouts

**Current Approach:**
- Uses `LayoutConstants` with fixed `Rect` boxes
- Deterministic randomness via `entry.id.hashCode + entry.layoutVariant`
- Staggering only in `TwoByOneLayout`

---

## Proposed Architecture

### 1. Data Models

**New file:** `app/lib/features/flipbook/models/layout_data.dart`

Define immutable data structures:

```dart
/// Position data for a single item (photo or map)
class ItemLayoutData {
  final String itemId;        // Photo ID or "location"
  final ItemType type;        // photo or map
  final double x;             // Left position (within content area)
  final double y;             // Top position (within content area)
  final double width;         // Polaroid width
  final double height;        // Polaroid height (including caption space)
  final double rotation;      // Rotation in degrees
}

enum ItemType { photo, map }

/// Complete layout data for a page
class PageLayoutData {
  final List<ItemLayoutData> items;  // All photos and maps
  final TextBlockLayout? textBlock;   // Text positioning
  final double contentPadding;        // Frame padding
}

/// Text block positioning (below items)
class TextBlockLayout {
  final double y;          // Top position
  final double maxWidth;   // Maximum text width
}
```

### 2. Layout Computation Service

**New file:** `app/lib/features/flipbook/services/layout_computer.dart`

Centralized service for computing exact coordinates:

**Key Methods:**
- `computeLayout(Entry entry, int layoutVariant) -> PageLayoutData`
  - Main entry point
  - Enforces max 4 items constraint
  - Delegates to position computation

- `_computeItemPositions(photos, hasLocation, totalItems, layoutVariant) -> List<ItemLayoutData>`
  - Computes exact (x, y, width, height, rotation) for each item
  - Handles all item counts: 0, 1, 2, 3, 4

- `_getPositionForIndex(index, totalItems, layoutVariant) -> (x, y)`
  - Returns coordinates based on item count and index
  - Implements layout patterns for each count

- `_generateRotation(itemId, layoutVariant) -> double`
  - Deterministic rotation angle (-5° to +5°)
  - Seeded by itemId hash + layoutVariant

- `_computeTextBlock(items) -> TextBlockLayout`
  - Positions text below lowest item
  - Ensures no overlap with photos/maps

**Layout Patterns:**

| Item Count | Layout Pattern |
|------------|----------------|
| 0 | No items (text only) |
| 1 | Single centered item (large) |
| 2 | Horizontal row, staggered vertically |
| 3 | **2 top row + 1 bottom centered** |
| 4 | 2×2 grid with staggering |

### 3. Unified Layout Widget

**New file:** `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart`

Single layout renderer that replaces all existing layouts:

**Responsibilities:**
- Call `LayoutComputer.computeLayout()` to get positions
- Render frame decoration
- Render date box (fixed position)
- Render items using `Stack` + `Positioned`
- Apply rotation transforms
- Render text block
- Render polaroids using existing widgets (`PolaroidPhoto`, `PolaroidMap`)

**Structure:**
```dart
class CoordinateLayout extends StatelessWidget {
  final Entry entry;
  final ColorScheme colorScheme;

  Widget build(context) {
    // 1. Compute layout data
    final layoutData = LayoutComputer.computeLayout(entry, entry.layoutVariant);

    // 2. Render background + frame
    // 3. Render date box (fixed)
    // 4. Render all items from layoutData
    // 5. Render text block
  }
}
```

### 4. Integration with Smart Page Renderer

**Modify:** `app/lib/features/flipbook/widgets/smart_page_renderer.dart`

Replace `_getLayoutWidget()` logic:

**Before:**
```dart
Widget _getLayoutWidget(ColorScheme colorScheme) {
  if (hasPhoto && hasLocation) return TwoByOneLayout(...);
  return SingleFullLayout(...);
}
```

**After:**
```dart
Widget _getLayoutWidget(ColorScheme colorScheme) {
  return CoordinateLayout(
    entry: widget.entry!,
    colorScheme: colorScheme,
  );
}
```

---

## Layout Constants

**Update:** `app/lib/features/flipbook/widgets/layout_constants.dart`

Add new constants for coordinate system:

```dart
class LayoutConstants {
  // ... existing constants ...

  // Item Sizes (Polaroid dimensions)
  static const double polaroidSizeXLarge = 420.0;  // 1 item
  static const double polaroidSizeLarge = 340.0;   // 2 items
  static const double polaroidSizeMedium = 280.0;  // 3 items
  static const double polaroidSizeSmall = 220.0;   // 4 items

  // Rotation Range
  static const double minRotation = -5.0;
  static const double maxRotation = 5.0;

  // Staggering Range (vertical offset for depth)
  static const double minStagger = 80.0;
  static const double maxStagger = 160.0;

  // Spacing
  static const double itemSpacingTwoItems = 32.0;
  static const double itemSpacingThreeItems = 28.0;
  static const double itemSpacingFourItems = 24.0;

  // Text positioning
  static const double textMarginAboveItems = 48.0;  // Space between items and text
}
```

---

## Detailed Layout Patterns

### 1 Item (Large, Centered)
```
┌─────────────────────┐
│       DATE          │
│                     │
│   ┌───────────┐     │
│   │           │     │
│   │  LARGE    │     │
│   │  ITEM     │     │
│   │           │     │
│   └───────────┘     │
│                     │
│      TEXT           │
└─────────────────────┘
```

**Specs:**
- Size: `420px` (polaroidSizeXLarge)
- Position: Horizontally centered, 15% from top
- Rotation: ±5° deterministic

### 2 Items (Side-by-Side, Staggered)
```
┌─────────────────────┐
│       DATE          │
│                     │
│  ┌────────┐         │
│  │ ITEM 1 │ ┌────┐  │
│  │        │ │ITEM│  │
│  └────────┘ │ 2  │  │
│             └────┘  │
│                     │
│      TEXT           │
└─────────────────────┘
```

**Specs:**
- Size: `340px` (polaroidSizeLarge)
- Spacing: `32px` horizontal gap
- Staggering: One item randomly offset up by 120-175px
- Position: Centered as group
- Rotation: ±5° deterministic per item

### 3 Items (2 Top, 1 Bottom Centered) ⭐ NEW
```
┌─────────────────────┐
│       DATE          │
│                     │
│  ┌─────┐  ┌─────┐   │
│  │ITEM1│  │ITEM2│   │
│  └─────┘  └─────┘   │
│                     │
│     ┌─────┐         │
│     │ITEM3│         │
│     └─────┘         │
│                     │
│      TEXT           │
└─────────────────────┘
```

**Specs:**
- Size: `280px` (polaroidSizeMedium)
- Top row spacing: `28px` horizontal gap
- Vertical gap: `24px` between rows
- Top row: Centered as group, 10% from top
- Bottom item: Horizontally centered
- Rotation: ±5° deterministic per item
- Staggering: Optional small random offsets per item

### 4 Items (2×2 Grid, Staggered)
```
┌─────────────────────┐
│       DATE          │
│                     │
│  ┌────┐  ┌────┐     │
│  │ 1  │  │ 2  │     │
│  └────┘  └────┘     │
│                     │
│  ┌────┐  ┌────┐     │
│  │ 3  │  │ 4  │     │
│  └────┘  └────┘     │
│                     │
│      TEXT           │
└─────────────────────┘
```

**Specs:**
- Size: `220px` (polaroidSizeSmall)
- Spacing: `24px` both horizontal and vertical
- Grid: 2 columns × 2 rows, centered
- Position: 8% from top
- Rotation: ±5° deterministic per item
- Staggering: Small random offsets for depth

---

## Migration Strategy

### Phase 1: Foundation
1. Create `layout_data.dart` models
2. Create `layout_computer.dart` service
3. Add new constants to `layout_constants.dart`

### Phase 2: Implementation
4. Implement `computeLayout()` core logic
5. Implement position computation for each item count (1, 2, 3, 4)
6. Implement rotation and staggering logic
7. Implement text block positioning

### Phase 3: Rendering
8. Create `coordinate_layout.dart` widget
9. Integrate with `PolaroidPhoto` and `PolaroidMap`
10. Handle empty state (0 items, text only)

### Phase 4: Integration
11. Update `smart_page_renderer.dart` to use `CoordinateLayout`
12. Remove old layout widgets (after verification)
13. Clean up unused constants

---

## Testing Plan

**Manual Testing Checklist:**

- [ ] 0 items (text only) - text centered, readable
- [ ] 1 photo - large, centered, rotated
- [ ] 1 location - large, centered, rotated
- [ ] 2 photos - side-by-side, staggered, rotated
- [ ] 1 photo + 1 location - side-by-side, staggered, rotated
- [ ] 3 photos - 2 top row, 1 bottom centered ⭐
- [ ] 2 photos + 1 location - 2 top row, 1 bottom centered ⭐
- [ ] 1 photo + 2 locations (future) - 2 top row, 1 bottom centered ⭐
- [ ] 4 photos - 2×2 grid, staggered, rotated
- [ ] 3 photos + 1 location - 2×2 grid, staggered, rotated

**Verification Criteria:**
- Items don't overlap
- Items fit within content box boundaries (726×1144px)
- Text doesn't overlap with items
- Rotations are deterministic (same entry = same rotation)
- Staggering is deterministic (same layoutVariant = same stagger)
- Layout regeneration button updates positions correctly

---

## Backend Compatibility

**Current Backend Fields:**
- `page_layout_type` (enum: `single_full`, `grid_2x2`, `grid_3x2`)
- NOT USED in current frontend (frontend determines layout from content)

**Future Migration Path:**
- Backend could compute and store coordinate data as JSONB
- Frontend would render pre-computed coordinates (true backend-authoritative)
- Current implementation is client-side temporary solution

**No backend changes required for this feature** - client-side only.

---

## Benefits

✅ **Unified rendering path** - One widget handles all item counts
✅ **3-item support** - Enables 2+1 layout pattern ⭐
✅ **4-item support** - Enables 2×2 grid with full staggering
✅ **Consistent behavior** - Same rotation/stagger logic everywhere
✅ **Flexible combinations** - Any mix of photos and maps (max 4 total)
✅ **Maintainable** - Single source of truth for positioning logic
✅ **Backend migration ready** - Data structures align with future JSONB schema
✅ **Deterministic** - Same content + layoutVariant = same layout

---

## Risks & Considerations

⚠️ **Breaking change** - Replaces existing layouts, requires thorough testing
⚠️ **Complex logic** - Position computation for all cases needs careful implementation
⚠️ **Performance** - Compute on every build, but should be negligible for simple math
⚠️ **Visual regression** - Existing 1-item and 2-item layouts must look identical

**Mitigation:**
- Test extensively with real entries before deploying
- Keep old layout widgets until verification complete
- Compare screenshots before/after for existing layouts
- Use layoutVariant consistently for deterministic results

---

## Future Enhancements (Post-V1)

- Backend-computed coordinates stored in JSONB field
- Support for multiple location maps (e.g., 2 photos + 2 maps)
- Collision detection for smarter staggering
- Customizable spacing/rotation ranges per entry
- Animation between layout regenerations

---

## Files to Create

1. `app/lib/features/flipbook/models/layout_data.dart` (new)
2. `app/lib/features/flipbook/services/layout_computer.dart` (new)
3. `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart` (new)

## Files to Modify

1. `app/lib/features/flipbook/widgets/layout_constants.dart` (add constants)
2. `app/lib/features/flipbook/widgets/smart_page_renderer.dart` (use new layout)

## Files to Delete (After Verification)

1. `app/lib/features/flipbook/widgets/layouts/single_full_layout.dart`
2. `app/lib/features/flipbook/widgets/layouts/two_by_one_layout.dart`
3. `app/lib/features/flipbook/widgets/layouts/grid_2x2_layout.dart` (if exists)
4. `app/lib/features/flipbook/widgets/layouts/grid_3x2_layout.dart` (if exists)

---

## Estimated Effort

- **Planning:** ✅ Complete (this document)
- **Models:** Small (simple data classes)
- **Service:** Large (core logic + position computation)
- **Widget:** Medium (rendering + integration)
- **Testing:** Medium (manual testing all combinations)
- **Cleanup:** Small (remove old files, update docs)

**Total:** Large effort

---

## Success Criteria

✅ All item count combinations (0-4) render correctly
✅ 3-item layout matches design specification (2 top, 1 bottom)
✅ Existing 1-item and 2-item layouts look visually identical
✅ Rotations and staggering are deterministic
✅ Layout regeneration produces different variations
✅ No content overflows frame boundaries
✅ Text positioning avoids item overlap
✅ Code is cleaner and more maintainable than before
