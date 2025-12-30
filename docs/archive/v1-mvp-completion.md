# V1 MVP Completion

**Phase:** V1 (Launch-Ready MVP)
**Created:** 2025-12-26
**Status:** In Progress
**Priority:** **Critical** (Blocks Launch)
**Effort:** Critical tasks for launch readiness

---

## Goal

Complete remaining V1 features to ship a polished, stable flipbook experience with automated Smart Pages.

---

## Current Status

### ✅ Complete
- Entry CRUD (create, read, update, delete)
- Photo upload to Supabase Storage
- Smart Pages Engine (backend computes layout type, color theme, sprinkles)
- Flipbook viewer with page navigation
- Single item layout (photo or map)
- Two item layout (photo + map, side-by-side with staggering)
- Polaroid-style photo rendering
- Location map rendering
- Authentication (signup, login, logout)
- Row Level Security (RLS) policies

### ⏳ Remaining Tasks

1. **Unified Coordinate Layout System** (Blocks: 3-4 item layouts)
2. **Flipbook Fade Transition** (Polish: smooth page swipes)
3. **Icon Placement System** (Feature: decorative sprinkles)

---

## Task 1: Unified Coordinate Layout System

**Priority:** Critical
**Effort:** Large
**Blocks:** 3-item and 4-item layouts
**Planning Doc:** `unified-coordinate-layout-system.md`

### Objective

Replace layout-specific widgets with a single coordinate-based system that handles any combination of 1-4 items (photos + location maps).

### Why This Matters

**Current Problem:**
- `SingleFullLayout` only handles 1 item
- `TwoByOneLayout` only handles photo + map
- No support for: 2 photos, 3 items, 4 items
- Inconsistent staggering logic

**Solution:**
- Single `CoordinateLayout` widget
- Handles 0-4 items with any combination
- Consistent rotation/staggering across all layouts
- Enables the critical **3-item layout** (2 top, 1 bottom)

### Implementation Steps

#### Step 1: Create Data Models

**File:** `app/lib/features/flipbook/models/layout_data.dart` (new)

```dart
class ItemLayoutData {
  final String itemId;
  final ItemType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
}

class PageLayoutData {
  final List<ItemLayoutData> items;
  final TextBlockLayout? textBlock;
}
```

#### Step 2: Create Layout Computer Service

**File:** `app/lib/features/flipbook/services/layout_computer.dart` (new)

**Core Logic:**
- `computeLayout(Entry entry, int layoutVariant) -> PageLayoutData`
- Position computation for 1-4 items
- Deterministic rotation and staggering
- Text block positioning (below items)

**Layout Patterns:**
- 1 item: Large, centered, 15% from top
- 2 items: Side-by-side, staggered vertically
- 3 items: 2 top row (centered) + 1 bottom (centered)
- 4 items: 2×2 grid, staggered

#### Step 3: Create Coordinate Layout Widget

**File:** `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart` (new)

**Responsibilities:**
- Call `LayoutComputer.computeLayout()`
- Render frame decoration
- Render date box (fixed position from `LayoutConstants`)
- Render items using `Stack` + `Positioned` with rotation
- Render text block

#### Step 4: Update Layout Constants

**File:** `app/lib/features/flipbook/widgets/layout_constants.dart`

Add:
- Polaroid sizes for each item count (1: 420px, 2: 340px, 3: 280px, 4: 220px)
- Rotation range (-5° to +5°)
- Staggering range (80-160px)
- Spacing constants

#### Step 5: Integration

**File:** `app/lib/features/flipbook/widgets/smart_page_renderer.dart`

Replace `_getLayoutWidget()` to use `CoordinateLayout` for all entries:

```dart
Widget _getLayoutWidget(ColorScheme colorScheme) {
  return CoordinateLayout(
    entry: widget.entry!,
    colorScheme: colorScheme,
  );
}
```

### Testing Checklist

- [ ] 0 items (text only) - text centered, no items
- [ ] 1 photo - large, centered, rotated
- [ ] 1 location - large, centered, rotated
- [ ] 2 photos - side-by-side, staggered, rotated
- [ ] 1 photo + 1 location - side-by-side, staggered, rotated
- [ ] **3 photos - 2 top row, 1 bottom centered** ⭐
- [ ] **2 photos + 1 location - 2 top row, 1 bottom centered** ⭐
- [ ] **4 photos - 2×2 grid, staggered, rotated** ⭐
- [ ] **3 photos + 1 location - 2×2 grid** ⭐
- [ ] Rotations deterministic (same entry + variant = same rotation)
- [ ] Items don't overlap
- [ ] Items fit within content box (726×1144px)
- [ ] Text doesn't overlap items
- [ ] Regenerate button changes layout (new layoutVariant)

### Files to Create

1. `app/lib/features/flipbook/models/layout_data.dart`
2. `app/lib/features/flipbook/services/layout_computer.dart`
3. `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart`

### Files to Modify

1. `app/lib/features/flipbook/widgets/layout_constants.dart` (add constants)
2. `app/lib/features/flipbook/widgets/smart_page_renderer.dart` (use new layout)

### Files to Delete (After Verification)

1. `app/lib/features/flipbook/widgets/layouts/single_full_layout.dart`
2. `app/lib/features/flipbook/widgets/layouts/two_by_one_layout.dart`
3. `app/lib/features/flipbook/widgets/layouts/grid_2x2_layout.dart` (if exists)
4. `app/lib/features/flipbook/widgets/layouts/grid_3x2_layout.dart` (if exists)

---

## Task 2: Flipbook Fade Transition

**Priority:** Medium (UX Polish)
**Effort:** Small
**Planning Doc:** `flipbook-fade-transition.md`

### Objective

Add smooth fade effect during horizontal page swipes for a professional reading experience.

### Implementation

**File:** `app/lib/features/flipbook/flipbook_viewer.dart`

**Changes:** Wrap `PageView.builder` items with `AnimatedBuilder` + `Opacity`:

```dart
PageView.builder(
  controller: _pageController,
  itemCount: pages.length,
  itemBuilder: (context, index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double opacity = 1.0;
        if (_pageController.position.haveDimensions) {
          final position = (_pageController.page ?? 0.0) - index;
          opacity = (1 - position.abs()).clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Container(
            color: Colors.grey.shade900,
            child: pages[index],
          ),
        ),
      ),
    );
  },
)
```

### Testing Checklist

- [ ] Fade works during manual swipe
- [ ] Fade works with prev/next buttons
- [ ] Smooth transition (no jank)
- [ ] Performance acceptable on web
- [ ] First page loads at full opacity
- [ ] Last page ("The End") fades correctly

---

## Task 3: Icon Placement System (Sprinkles)

**Priority:** Medium (Visual Polish)
**Effort:** Medium
**Planning Doc:** `icon-placement-system.md`
**Dependencies:** Task 1 (coordinate layout system)

### Objective

Place decorative icons (sprinkles) on pages with collision detection to avoid overlapping photos, maps, or text.

### Implementation Steps

#### Step 1: Update Data Models

**File:** `app/lib/features/flipbook/models/layout_data.dart`

Add `IconLayoutData` class:

```dart
class IconLayoutData {
  final String iconName;
  final double x;
  final double y;
  final double rotation;
  final double size;

  Rect get boundingBox => Rect.fromLTWH(x, y, size, size);
}
```

Update `PageLayoutData`:

```dart
class PageLayoutData {
  final List<ItemLayoutData> items;
  final List<IconLayoutData> icons; // NEW
  final TextBlockLayout? textBlock;
}
```

#### Step 2: Implement Icon Placement Logic

**File:** `app/lib/features/flipbook/services/layout_computer.dart`

Add methods:
- `_computeIconPositions()` - Main logic
- `_findIconPosition()` - Find non-colliding position
- `_getItemBoundingBox()` - Get collision boxes

**Algorithm:**
1. Build list of occupied regions (photos, maps, text + padding)
2. For each sprinkle (max 3):
   - Generate random position using seeded random
   - Check collision with all occupied regions
   - Retry up to 20 times if collision detected
   - Add to icons list if valid position found
3. Return icon layout data

#### Step 3: Render Icons

**File:** `app/lib/features/flipbook/widgets/layouts/coordinate_layout.dart`

Add icon rendering:

```dart
Stack(
  children: [
    // Background + frame
    ...

    // Content area
    Padding(
      padding: ...,
      child: Stack(
        children: [
          // Icons FIRST (behind photos)
          ...layoutData.icons.map((icon) => _buildIcon(icon)),

          // Photos and maps
          ...layoutData.items.map((item) => _buildItem(item)),

          // Text (always on top)
          if (layoutData.textBlock != null) _buildTextBlock(...),
        ],
      ),
    ),
  ],
)
```

#### Step 4: Icon Asset Mapping

Map sprinkle names from backend to Material Icons:

```dart
IconData _getIconFromName(String iconName) {
  switch (iconName) {
    case 'heart': return Icons.favorite;
    case 'star': return Icons.star;
    case 'mountain': return Icons.terrain;
    case 'beach': return Icons.beach_access;
    case 'airplane': return Icons.flight;
    case 'utensils': return Icons.restaurant;
    case 'gift': return Icons.card_giftcard;
    case 'balloon': return Icons.celebration;
    default: return Icons.star;
  }
}
```

### Testing Checklist

- [ ] Icons appear on pages with sprinkles
- [ ] Max 3 icons per page
- [ ] Icons don't overlap photos
- [ ] Icons don't overlap maps
- [ ] Icons don't overlap text
- [ ] Icons stay within content bounds
- [ ] Icon positions deterministic (same entry = same positions)
- [ ] Icon rotations random (-15° to +15°)
- [ ] Icons render with semi-transparent color
- [ ] Pages without sprinkles show no icons

### Design Decision Needed

**Question:** Should icons appear **behind** or **in front** of photos?

**Option A: Behind (Recommended)**
- Icons as subtle background decoration
- Photos remain focal point
- Less visual competition

**Option B: In Front**
- Icons as stickers/stamps
- More scrapbook aesthetic
- Could obscure photo details

**Current Implementation:** Behind photos (stack order)

---

## Launch Readiness Checklist

### Features Complete
- [ ] Unified coordinate layout (1-4 items)
- [ ] Fade transition on page swipes
- [ ] Icon placement with collision detection
- [ ] All layout types tested manually

### Testing Complete
- [ ] Entry creation flow (photos, text, tags, location)
- [ ] Smart Pages computation (layout, colors, sprinkles)
- [ ] Flipbook rendering (all item counts)
- [ ] Page navigation (swipe + buttons)
- [ ] Layout regeneration button
- [ ] Authentication flow
- [ ] RLS policies enforced

### Performance Verified
- [ ] Initial page load < 3s on 3G
- [ ] Page transitions smooth (60 FPS)
- [ ] No memory leaks during long sessions
- [ ] Works on Chrome, Firefox, Safari

### Bug Fixes
- [ ] No critical bugs
- [ ] No medium bugs blocking UX
- [ ] Low priority bugs documented for V1.5

### Documentation Updated
- [ ] `docs/CHANGES.md` updated with V1 completion
- [ ] `docs/testing-guide.md` reflects current features
- [ ] `CLAUDE.md` updated if architecture changed
- [ ] Planning docs moved to archive

---

## Success Criteria

✅ **All item count combinations work** (0, 1, 2, 3, 4 items)
✅ **3-item layout renders correctly** (2 top, 1 bottom)
✅ **Smooth page transitions** with fade effect
✅ **Icons placed without collisions**
✅ **Comprehensive manual testing complete**
✅ **Ready for public launch**

---

## Post-Launch Monitoring

1. **Gather user feedback** on layout quality
2. **Monitor error logs** for layout computation failures
3. **Track performance metrics** (load times, FPS)
4. **Document edge cases** encountered in production
5. **Plan V1.5 improvements** based on real usage

---

## Rollback Plan

If critical bugs discovered post-launch:

1. **Immediate:** Disable layout regeneration button (if that's the issue)
2. **Short-term:** Revert to previous layout system (keep old files temporarily)
3. **Long-term:** Fix bugs and redeploy

**Keep old layout files until V1 is stable in production.**

---

## Next Steps After V1 Launch

1. Monitor production for 1-2 weeks
2. Gather user feedback
3. Address critical bugs
4. Begin planning V1.5 (see `v1.5-ux-polish-and-database-prep.md`)

---

**This is the final push to launch. Let's ship! 🚀**
