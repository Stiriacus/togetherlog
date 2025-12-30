# Page Dimensions & Content Box Visualization

**Created:** 2024-12-24
**Status:** Ready to Implement
**Priority:** High (Foundation)
**Effort:** Small
**Dependencies:** None

---

## Goal

Define fixed page dimensions (DIN A5) with proportional scaling, and add a debug content box visualization to determine optimal padding within the decorative frame.

---

## Page Dimensions

### Fixed Aspect Ratio
**DIN A5:** 800px × 1142px (0.7 aspect ratio)

**Scaling Behavior:**
- Dimensions are **logical** - scale proportionally on smaller screens
- Aspect ratio **always** 0.7 (never distorted)
- All content (photos, icons, text) scales proportionally with page size
- Frame decoration scales with page size

### Implementation
**File:** `app/lib/features/flipbook/flipbook_viewer.dart`

**Current code (line 192-199):**
```dart
return Center(
  child: AspectRatio(
    aspectRatio: 0.7, // Portrait book aspect ratio
    child: Container(
      color: Colors.grey.shade900,
      child: pages[index],
    ),
  ),
);
```

**Status:** ✅ Already implemented correctly

---

## Content Box Visualization (Debug Tool)

### Purpose
Visualize the **usable content area** within the decorative frame to help determine optimal padding.

**Use case:** When testing layouts, enable content box to see exact boundaries where photos/icons/text can be placed.

### Visual Design
- **Border:** 2px dashed red line
- **Semi-transparent overlay:** Red @ 5% opacity
- **Corner labels:** Show padding values (top, right, bottom, left)
- **Toggle:** Debug flag to enable/disable

### Implementation

**New file:** `app/lib/features/flipbook/widgets/debug_content_box.dart`

```dart
import 'package:flutter/material.dart';

/// Debug widget to visualize usable content area within frame
/// Shows exact boundaries for photo/icon placement
class DebugContentBox extends StatelessWidget {
  const DebugContentBox({
    required this.padding,
    required this.enabled,
    super.key,
  });

  final EdgeInsets padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return Positioned.fill(
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            // Semi-transparent overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),

            // Corner labels showing padding values
            Positioned(
              top: 4,
              left: 4,
              child: _PaddingLabel(
                'T: ${padding.top.toInt()}  L: ${padding.left.toInt()}',
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: _PaddingLabel(
                'B: ${padding.bottom.toInt()}  R: ${padding.right.toInt()}',
              ),
            ),

            // Center crosshair
            Center(
              child: Icon(
                Icons.add,
                color: Colors.red.withValues(alpha: 0.3),
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaddingLabel extends StatelessWidget {
  const _PaddingLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
```

### Integration

**File:** `app/lib/features/flipbook/widgets/layouts/single_full_layout.dart` (and other layouts)

```dart
// Add debug flag constant at top of file
const bool _kShowContentBox = true; // Set to false in production

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Background surface
      Container(color: colorScheme.surface),

      // Decorative frame
      Positioned.fill(
        child: Image.asset(
          'assets/images/decorations/classic_boarder_olivebrown.png',
          fit: BoxFit.contain,
        ),
      ),

      // Content
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
        child: _buildContent(),
      ),

      // DEBUG: Content box visualization
      DebugContentBox(
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
        enabled: _kShowContentBox,
      ),
    ],
  );
}
```

---

## Current Padding Values

**File:** All layout widgets

**Current implementation:**
```dart
padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0)
```

**Usable content area:**
- Width: 800 - (64 * 2) = **672px**
- Height: 1142 - (48 * 2) = **1046px**

**To test different padding:**
1. Enable content box (`_kShowContentBox = true`)
2. Adjust padding values
3. Run app and observe red boundary
4. Find optimal balance between frame visibility and content space

---

## Constants Definition

**New file:** `app/lib/features/flipbook/constants/page_constants.dart`

```dart
/// Flipbook page dimension and layout constants
class PageConstants {
  PageConstants._(); // Private constructor - static class only

  // Page dimensions (DIN A5 aspect ratio)
  static const double pageWidth = 800.0;
  static const double pageHeight = 1142.0;
  static const double aspectRatio = 0.7;

  // Content padding (space reserved for frame decoration)
  static const double horizontalPadding = 64.0;
  static const double verticalPadding = 48.0;

  // Usable content area
  static const double contentWidth = pageWidth - (horizontalPadding * 2); // 672
  static const double contentHeight = pageHeight - (verticalPadding * 2); // 1046

  // Maximum items per page
  static const int maxPhotosAndMaps = 4; // Total photos + location maps

  // Debug
  static const bool showContentBox = false; // Enable during development
}
```

**Usage:**
```dart
import '../constants/page_constants.dart';

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: PageConstants.horizontalPadding,
    vertical: PageConstants.verticalPadding,
  ),
  child: ...
)
```

---

## Testing Checklist

- [ ] Create `page_constants.dart` with page dimensions
- [ ] Create `debug_content_box.dart` widget
- [ ] Integrate content box into all layout widgets
- [ ] Enable content box (`showContentBox = true`)
- [ ] Run flipbook and verify red boundary appears
- [ ] Test different padding values (try 56, 64, 72 for horizontal)
- [ ] Test different padding values (try 40, 48, 56 for vertical)
- [ ] Find optimal padding where:
  - Frame decoration is fully visible
  - Maximum content space is preserved
  - Content never overlaps frame borders
- [ ] Update `PageConstants` with final padding values
- [ ] Disable content box (`showContentBox = false`) before commit

---

## Benefits

✅ **Fixed dimensions** — Consistent aspect ratio across all devices
✅ **Visual debugging** — See exact usable space boundaries
✅ **Easy iteration** — Toggle content box on/off for testing
✅ **Centralized constants** — Single source of truth for dimensions
