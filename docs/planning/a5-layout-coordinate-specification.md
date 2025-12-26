# A5 Layout Coordinate Specification

**Page Size:** DIN A5 at 150 DPI = **874×1240 pixels**

**Purpose:** Define precise pixel coordinate areas for all layout zones

---

## Visual Overview

```
┌─────────────────────────────────────────────────────┐
│ 874×1240                                            │
│ ┌─────────────────────────────────────────────────┐ │
│ │ FRAME (74px padding)                            │ │
│ │ ┌─────────────────────────────────────────────┐ │ │
│ │ │ CONTENT AREA (726×1144)                     │ │ │
│ │ │                                             │ │ │
│ │ │        ┌──────────────┐                     │ │ │
│ │ │        │ DATE BOX     │ (307,100) 242×60   │ │ │
│ │ │        └──────────────┘                     │ │ │
│ │ │                                             │ │ │
│ │ │ ┌─────────────────────────────────────────┐ │ │ │
│ │ │ │                                         │ │ │ │
│ │ │ │     CONTENT BOX (74,230) 726×740       │ │ │ │
│ │ │ │     [Photos/Maps/Icons live here]      │ │ │ │
│ │ │ │                                         │ │ │ │
│ │ │ │                                         │ │ │ │
│ │ │ └─────────────────────────────────────────┘ │ │ │
│ │ │                                             │ │ │
│ │ │        ┌──────────────────┐                 │ │ │
│ │ │        │  TEXT BOX        │ (200,980)       │ │ │
│ │ │        │  474×160         │                 │ │ │
│ │ │        └──────────────────┘                 │ │ │
│ │ └─────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

## 1. Frame Area

**Purpose:** Decorative border (PNG overlay)

**Coordinates:**
- **Full Page:** (0, 0) → (874, 1240)
- **Asset:** `classic_boarder_olivebrown.png`
- **Rendering:** `BoxFit.contain` centered

**Padding (reserved for frame):**
- **Horizontal:** 74px (left + right)
- **Vertical:** 48px (top + bottom)

**Implementation:**
```dart
Positioned.fill(
  child: Image.asset(
    'assets/images/decorations/classic_boarder_olivebrown.png',
    fit: BoxFit.contain,
  ),
)
```

---

## 2. Content Area (Usable Space)

**Purpose:** All content must fit inside this area

**Coordinates:**
- **X:** 74px (left edge)
- **Y:** 48px (top edge)
- **Width:** 726px (874 - 148)
- **Height:** 1144px (1240 - 96)
- **Bounds:** (74, 48) → (800, 1192)

**Critical Constraint:**
- Photos, maps, icons, text MUST NOT exceed these boundaries
- This is the absolute hard limit for all visual elements

---

## 3. Date Box

**Purpose:** Display event date (e.g., "December 25, 2024")

**Coordinates:**
- **X:** 307px (from left edge)
- **Y:** 100px (from top edge)
- **Width:** 242px
- **Height:** 60px
- **Bounds:** (307, 100) → (549, 160)

**Typography:**
- **Font:** Google Fonts - Just Another Hand
- **Size:** 32px
- **Weight:** 400 (Regular)
- **Color:** `colorScheme.primary`
- **Alignment:** Center

**Layout:**
- Horizontally centered (~307px calculated as `framePaddingHorizontal * 4.15`)
- Fixed position (DO NOT MODIFY)

**Implementation:**
```dart
Positioned(
  left: 307,
  top: 100,
  width: 242,
  height: 60,
  child: Center(
    child: Text(
      dateFormatter.format(entry.eventDate),
      style: GoogleFonts.justAnotherHand(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.primary,
      ),
    ),
  ),
)
```

---

## 4. Content Box (Photos/Maps/Icons)

**Purpose:** Main visual content area for photos, location maps, and decorative icons

### Single Item Layout

**Coordinates:**
- **X:** 74px
- **Y:** 230px
- **Width:** 726px
- **Height:** 740px
- **Bounds:** (74, 230) → (800, 970)

**Usage:**
- 0-1 photos OR
- 0-1 location map

**Polaroid Size:**
- **Large:** 420px (for single item)

### Two Item Layout (2×1)

**Photo Box (Left):**
- **Base X:** 84px
- **Base Y:** 430px
- **Width:** 340px
- **Height:** 480px
- **Bounds:** (84, 430) → (424, 910)

**Map Box (Right):**
- **Base X:** 450px
- **Base Y:** 430px
- **Width:** 340px
- **Height:** 480px
- **Bounds:** (450, 430) → (790, 910)

**Vertical Staggering:**
- **Min Offset:** -120px (move up)
- **Max Offset:** -175px (move up)
- **Application:** One item randomly offset for visual depth

**Polaroid Size:**
- **Medium:** 340px (for 2 items)

### Future Multi-Item Layouts (3-4 items)

**To be defined** in unified coordinate layout system:
- 3 items: 2 top row + 1 bottom centered
- 4 items: 2×2 grid
- Sizes: 280px (3 items), 220px (4 items)

**Constraint:**
- All items + gaps MUST fit within (74, 230) → (800, 970)

---

## 5. Text Box (Highlight Text)

**Purpose:** Display entry highlight text (title/description)

**Coordinates:**
- **X:** 200px
- **Y:** 980px
- **Width:** 474px
- **Height:** 160px
- **Bounds:** (200, 980) → (674, 1140)

**Typography:**
- **Font:** Google Fonts - Just Another Hand
- **Size:** 28px
- **Weight:** 400 (Regular)
- **Color:** `colorScheme.onSurface`
- **Line Height:** 1.3
- **Max Lines:** 3
- **Overflow:** Ellipsis
- **Alignment:** Center

**Layout:**
- Centered horizontally below content box
- Fixed position (DO NOT MODIFY)

**Implementation:**
```dart
Positioned(
  left: 200,
  top: 980,
  width: 474,
  height: 160,
  child: Center(
    child: Text(
      entry.highlightText,
      style: GoogleFonts.justAnotherHand(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  ),
)
```

---

## 6. Icon Placement Area (Sprinkles)

**Purpose:** Decorative tag-based icons that don't overlap content

**Available Space:**
- Content Area MINUS occupied regions (photos, maps, text)
- Icons placed using collision detection algorithm

**Icon Specs:**
- **Size:** 32×32px
- **Rotation:** -15° to +15°
- **Max Count:** 3 per page
- **Z-Index:** Behind photos/maps (or in front, TBD)

**Placement Algorithm:**
1. Build occupied regions (photos + maps + text + padding)
2. Generate random position within content area
3. Check collision with all occupied regions
4. Retry up to 20 times if collision
5. Place icon if valid position found

**Constraints:**
- Must stay within content area (74, 48) → (800, 1192)
- Must NOT overlap photos, maps, or text
- Minimum 16px padding around items

---

## Zone Summary Table

| Zone | X | Y | Width | Height | Bounds | Notes |
|------|---|---|-------|--------|--------|-------|
| **Page** | 0 | 0 | 874 | 1240 | (0,0)→(874,1240) | Full canvas |
| **Frame** | 0 | 0 | 874 | 1240 | Full page | PNG overlay |
| **Content Area** | 74 | 48 | 726 | 1144 | (74,48)→(800,1192) | Hard boundary |
| **Date Box** | 307 | 100 | 242 | 60 | (307,100)→(549,160) | FIXED |
| **Single Content** | 74 | 230 | 726 | 740 | (74,230)→(800,970) | 0-1 items |
| **2×1 Photo** | 84 | 430 | 340 | 480 | (84,430)→(424,910) | Base position |
| **2×1 Map** | 450 | 430 | 340 | 480 | (450,430)→(790,910) | Base position |
| **Text Box** | 200 | 980 | 474 | 160 | (200,980)→(674,1140) | FIXED |

---

## Vertical Layout Flow

```
Y = 0      ┌─ Page Top
           │
Y = 48     ├─ Content Area Begins
           │
Y = 100    ├─ DATE BOX (60px height)
Y = 160    │
           │
Y = 230    ├─ CONTENT BOX Begins (740px height)
           │  [Photos, Maps, Icons]
           │
Y = 970    ├─ CONTENT BOX Ends
           │
Y = 980    ├─ TEXT BOX Begins (160px height)
Y = 1140   │
           │
Y = 1192   ├─ Content Area Ends
           │
Y = 1240   └─ Page Bottom
```

---

## Horizontal Layout Flow

```
X = 0      ┌─ Page Left
           │
X = 74     ├─ Content Area Left Edge
           │  Frame Padding
           │
X = 84     ├─ Photo Left Edge (2×1 layout)
           │
X = 307    ├─ Date Box Left Edge (centered)
           │
X = 424    ├─ Photo Right Edge (2×1 layout)
           │
X = 450    ├─ Map Left Edge (2×1 layout)
           │
X = 549    ├─ Date Box Right Edge
           │
X = 790    ├─ Map Right Edge (2×1 layout)
           │
X = 800    ├─ Content Area Right Edge
           │  Frame Padding
           │
X = 874    └─ Page Right
```

---

## Spacing & Gaps

### Between Content and Text
- **Content Box Bottom:** Y = 970
- **Text Box Top:** Y = 980
- **Gap:** 10px

### Between Date and Content
- **Date Box Bottom:** Y = 160
- **Content Box Top:** Y = 230
- **Gap:** 70px

### Between Items (2×1 Layout)
- **Photo Right Edge:** X = 424
- **Map Left Edge:** X = 450
- **Gap:** 26px

---

## Implementation Notes

### Fixed Elements (DO NOT MODIFY)
- **Date Box:** Position and size are final
- **Text Box:** Position and size are final
- **Frame Padding:** 74px/48px is optimal for current frame asset

### Flexible Elements (Can Adjust)
- **Content Box:** Item positioning within this area can vary
- **Icon Placement:** Random within available space
- **Item Staggering:** Vertical offsets for depth

### Future Considerations
- Content box may be subdivided for 3-4 item layouts
- Icon z-index (behind vs. in front) TBD
- Potential for multiple text blocks in V2 editor

---

## Color Coding (Debug Mode)

When `_kShowContentBox = true`:

| Zone | Border Color | Background Alpha |
|------|--------------|------------------|
| Date Box | Blue (#0000FF) | 10% |
| Content Box | Green (#00FF00) | 10% |
| Text Box | Orange (#FFA500) | 10% |

**Implementation:**
```dart
decoration: BoxDecoration(
  color: Colors.green.withValues(alpha: 0.1),
  border: Border.all(color: Colors.green, width: 2),
),
```

---

## Reference Files

**Current Implementation:**
- `app/lib/features/flipbook/widgets/layouts/single_full_layout.dart`
- `app/lib/features/flipbook/widgets/layout_constants.dart`

**Future Implementation:**
- `app/lib/features/flipbook/services/layout_computer.dart` (unified system)
- `app/lib/features/flipbook/models/layout_data.dart` (coordinate models)

---

## Design Rationale

### Why These Coordinates?

1. **Date Box (307, 100):** Centered horizontally, high enough to be visible but not competing with main content
2. **Content Box (74, 230):** Maximum usable space within frame, balanced vertical positioning
3. **Text Box (200, 980):** Centered horizontally, near bottom for traditional scrapbook layout
4. **Frame Padding (74/48):** Optimal for current frame asset visibility

### Constraints Validated

✅ All zones fit within page bounds (874×1240)
✅ No overlapping zones
✅ Content area respects frame padding
✅ Text readable with sufficient padding
✅ Photos large enough to be meaningful (420px single, 340px dual)

---

**This document defines the exact pixel coordinate specification for TogetherLog's A5 flipbook layout.**

**Status:** Based on current implementation as of 2025-12-26
**Usage:** Reference for layout implementation, coordinate calculations, and collision detection
