# Feature Request: Stable Gutter-Based Editor Layout

## Overview
Redesign the page editor to use a professional three-column gutter-based layout architecture where the canvas remains fixed and fully visible at all times, with stable tool and property panels on the left and right.

## Problem Statement
The current editor architecture has fundamental UX issues:
- Sliding panels push or overlay the canvas, obscuring content
- Canvas size/position changes when panels open/close
- Difficult to select, rotate, or adjust items near page edges
- Unprofessional layout that doesn't follow industry standards
- No stable workspace for the fixed-size scrapbook page (874px × 1240px)

## Design Principles

### 1. Canvas as Protected Workspace
- **Canvas must never be resized, pushed, scaled, or covered by UI panels**
- Canvas size is fixed at 874px × 1240px (DIN A5 at 150 DPI)
- All UI changes occur outside the canvas bounds
- Canvas remains fully visible and interactive at all times

### 2. Three-Column Layout Architecture

```
┌────────────────────────────────────────────────────────────┐
│  AppBar (Menu, Log Name, Save Button)                      │
├──────────────┬─────────────────────────┬───────────────────┤
│              │                         │                   │
│  Left Gutter │   Canvas (Fixed)        │  Right Gutter     │
│              │   874 × 1240px          │                   │
│  Tools &     │                         │  Properties       │
│  Assets      │   ┌─────────────────┐   │                   │
│              │   │                 │   │  Selection-based  │
│  - Photos    │   │   Scrapbook     │   │  controls:        │
│  - Decor     │   │   Page          │   │                   │
│  - Bg Color  │   │                 │   │  - Rotation       │
│  - Layers    │   │                 │   │  - Size           │
│              │   │                 │   │  - Position       │
│  (Stable     │   │                 │   │  - Opacity        │
│   width)     │   │                 │   │  - Z-index        │
│              │   │                 │   │                   │
│              │   └─────────────────┘   │  (Stable width)   │
│              │                         │                   │
└──────────────┴─────────────────────────┴───────────────────┘
```

## Detailed Specification

### Left Gutter — Tools & Asset Selection

**Purpose**: Tool mode switching, asset browsing, structural navigation

**Content**:
1. **Tool/Mode Selection** (always visible):
   - Photos button → Opens photo picker/grid
   - Decorations button → Opens decoration picker/grid
   - Background Color button → Opens color picker
   - Layers button → Shows layer list with reordering

2. **Behavior**:
   - Fixed width (e.g., 280-320px)
   - Always visible (never collapses by default)
   - Optional: Minimize to icon-only mode (48-64px wide)
   - Collapsing must NOT affect canvas position or size

3. **Layout**:
   - Vertically stacked sections
   - Each section can be collapsed independently
   - Scrollable if content exceeds viewport height

**Example Structure**:
```
┌─ Left Gutter ────────────┐
│ ▼ Photos                 │
│   [Photo grid/picker]    │
│                          │
│ ▼ Decorations            │
│   [Decoration grid]      │
│                          │
│ ▼ Background             │
│   [Color picker]         │
│                          │
│ ▼ Layers                 │
│   #1 Photo 1    👁 ↑↓⋮  │
│   #2 Photo 2    👁 ↑↓⋮  │
│   #3 Decoration 👁 ↑↓⋮  │
└──────────────────────────┘
```

### Center — Canvas (Fixed Workspace)

**Purpose**: The scrapbook page workspace

**Constraints**:
- **Fixed size**: 874px × 1240px (never changes)
- **Centered** in available space between gutters
- **Scrollable** if viewport is smaller than canvas + gutters
- **Never overlapped** by panels or UI elements
- **Never compressed** or resized

**Padding**:
- Top/Bottom: 48px minimum
- Left/Right: Auto-centered with scrollbars if needed

### Right Gutter — Properties & Details

**Purpose**: Context-sensitive controls for selected items

**Content**:
1. **Selection-based controls** (visible when item is selected):
   - Rotation controls (slider, buttons, precise input)
   - Size controls (width, height, lock aspect ratio)
   - Position controls (X, Y coordinates)
   - Opacity slider
   - Z-index controls (bring forward, send backward)
   - Delete button

2. **Empty state** (when nothing is selected):
   - "Select an item to edit its properties"
   - Or show page-level properties (background color, etc.)

3. **Behavior**:
   - Fixed width (e.g., 280-320px)
   - Always visible (stable layout)
   - Content updates based on selection
   - Sections can collapse independently
   - Collapsing sections must NOT cause layout reflow

**Example Structure**:
```
┌─ Right Gutter ───────────┐
│ Properties               │
│                          │
│ ▼ Rotation               │
│   Slider: [-180°][+180°] │
│   Current: 45°           │
│   [↺-90°][-15°][0°][+15°][↻+90°] │
│   Precise: [45]° ↑↓      │
│                          │
│ ▼ Size                   │
│   Width:  [200]px        │
│   Height: [300]px        │
│   [🔒] Lock aspect       │
│                          │
│ ▼ Position               │
│   X: [100]px             │
│   Y: [200]px             │
│                          │
│ ▼ Appearance             │
│   Opacity: [━━━●━━] 100% │
│                          │
│ [🗑️ Delete Item]         │
└──────────────────────────┘
```

## Layout Calculations

### Minimum Window Width
```
Left Gutter (280px) + Canvas (874px) + Right Gutter (280px) = 1434px minimum
```

### Responsive Behavior
- **Window < 1434px**: Horizontal scrollbar appears
- **Window ≥ 1434px**: Canvas centered, no horizontal scroll
- **Window > 1434px**: Extra space distributed to gutters or margins

### Optional: Gutter Collapse
If implementing collapsible gutters:
- Left gutter collapses to icon-only (48px)
- Right gutter can hide completely (0px)
- Canvas position/size remains unchanged
- Collapsing creates more viewport space, not canvas space

## Implementation Plan

### Phase 1: Layout Structure
1. Create three-column layout container
2. Define fixed widths and constraints
3. Implement horizontal scrolling for small viewports
4. Center canvas in available space

### Phase 2: Left Gutter
1. Move toolbar buttons into left gutter
2. Implement collapsible sections (Photos, Decorations, Background, Layers)
3. Style asset pickers and layer list
4. Ensure stable width (no layout shift)

### Phase 3: Right Gutter
1. Create properties panel widget
2. Implement rotation controls section
3. Add size, position, opacity controls
4. Add delete button
5. Handle selection state (show/hide relevant sections)

### Phase 4: Polish
1. Smooth section expand/collapse animations
2. Persist gutter collapse state
3. Keyboard shortcuts for panel toggling
4. Responsive refinements

## Technical Requirements

### Flutter Implementation
```dart
Row(
  children: [
    // Left Gutter (stable width)
    Container(
      width: 280,
      child: LeftGutterPanel(),
    ),

    // Canvas (fixed size, scrollable)
    Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: 874,
            height: 1240,
            child: EditorCanvas(),
          ),
        ),
      ),
    ),

    // Right Gutter (stable width)
    Container(
      width: 280,
      child: RightGutterPanel(),
    ),
  ],
)
```

### State Management
- Left gutter sections: Collapse state per section
- Right gutter: Reactive to `selectedItemId`
- Canvas: Independent, unaffected by gutter state

## Design Tokens

### Gutter Widths
- Default: 280px
- Minimum (collapsed): 48px (left only)
- Maximum: 400px (optional for larger screens)

### Spacing
- Section padding: 12px
- Section margin: 8px
- Control spacing: 8px

### Colors (from design system)
- Gutter background: `AppColors.antiqueWhite`
- Section header: `AppColors.darkWalnut`
- Dividers: `AppColors.divider`

## Acceptance Criteria

- [ ] Three-column layout implemented
- [ ] Canvas remains fixed at 874px × 1240px at all times
- [ ] Canvas never overlapped by panels
- [ ] Left gutter contains Photos, Decorations, Background, Layers
- [ ] Right gutter contains Rotation, Size, Position, Opacity controls
- [ ] Gutters have stable, fixed widths
- [ ] Collapsible sections don't cause layout reflow
- [ ] Horizontal scrollbar appears when window < 1434px
- [ ] Canvas centered when window ≥ 1434px
- [ ] All controls functional and properly connected to state
- [ ] Professional appearance matching design system

## Benefits

✅ **Professional UX**: Follows industry standards (Figma, Photoshop, Canva)
✅ **Stable workspace**: Canvas never moves or resizes
✅ **Always visible**: No obscured content or edge-case interaction issues
✅ **Scalable**: Easy to add new tools and properties
✅ **Predictable**: Users know where to find tools and properties
✅ **Efficient**: No panel shuffling, everything in its place

## References

Industry examples using gutter-based layouts:
- Figma: Left tools, center canvas, right properties
- Photoshop: Left tools, center canvas, right layers/properties
- Canva: Left templates/elements, center canvas, right properties
- Sketch: Left layers, center canvas, right inspector

## Migration Notes

### Files to Modify
- `editor_screen.dart` - Complete layout restructure
- `editor_toolbar.dart` - Move into left gutter
- `tools_panel.dart` - Split into left and right gutters
- `layers_panel.dart` - Move into left gutter

### Files to Create
- `left_gutter_panel.dart` - Tool and asset selection
- `right_gutter_panel.dart` - Properties panel
- `canvas_wrapper.dart` - Fixed canvas container with scrolling

### Deprecated Patterns
- ❌ Sliding panels (AnimatedContainer width changes)
- ❌ Overlay panels (Stack with positioned panels)
- ❌ Canvas width calculations based on panel state
- ❌ Toolbar as separate horizontal row

### New Patterns
- ✅ Fixed three-column Row layout
- ✅ Stable gutter widths
- ✅ Scrollable canvas container
- ✅ Vertical tool navigation
- ✅ Context-sensitive properties

## Priority
**High** - Fundamental UX improvement that enables professional editing workflow

## Estimated Effort
**Medium-Large** - 6-8 hours for complete implementation and polish
- Layout restructure: 2-3 hours
- Left gutter migration: 2 hours
- Right gutter creation: 2 hours
- Polish and testing: 1-2 hours
