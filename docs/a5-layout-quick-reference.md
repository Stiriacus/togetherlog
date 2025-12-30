# A5 Layout Quick Reference

**Page:** 874×1240 px | **Content Area:** 726×1144 px

---

## Coordinate Cheat Sheet

```
┌────────────────────────────────────────┐
│  874 × 1240 (DIN A5 @ 150 DPI)        │
│                                        │
│  ┌──────────────────────────────────┐  │ Frame Padding
│  │  726 × 1144 Content Area         │  │ H: 74px
│  │                                  │  │ V: 48px
│  │    ┌──────────────┐              │  │
│  │    │  DATE BOX    │ 307,100      │  │
│  │    │  242×60      │              │  │
│  │    └──────────────┘              │  │
│  │                                  │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │                            │  │  │
│  │  │     CONTENT BOX            │  │  │
│  │  │     74,230                 │  │  │
│  │  │     726×740                │  │  │
│  │  │     [Photos/Maps/Icons]    │  │  │
│  │  │                            │  │  │
│  │  └────────────────────────────┘  │  │
│  │                                  │  │
│  │      ┌──────────────┐            │  │
│  │      │  TEXT BOX    │ 200,980    │  │
│  │      │  474×160     │            │  │
│  │      └──────────────┘            │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

---

## Zone Coordinates

| Zone | Position (X,Y) | Size (W×H) | Bounds |
|------|----------------|------------|--------|
| **Page** | 0, 0 | 874×1240 | (0,0) → (874,1240) |
| **Content Area** | 74, 48 | 726×1144 | (74,48) → (800,1192) |
| **Date** | 307, 100 | 242×60 | (307,100) → (549,160) |
| **Content** | 74, 230 | 726×740 | (74,230) → (800,970) |
| **Text** | 200, 980 | 474×160 | (200,980) → (674,1140) |

---

## Two Item Layout (2×1)

```
┌─────────────────────────────────────┐
│         Content Box 726×740         │
│                                     │
│   ┌────────┐         ┌────────┐    │
│   │ PHOTO  │   26px  │  MAP   │    │
│   │ 340×   │   gap   │ 340×   │    │
│   │  480   │         │  480   │    │
│   │        │         │        │    │
│   │ 84,430 │         │450,430 │    │
│   └────────┘         └────────┘    │
│                                     │
│   One randomly offset by 120-175px  │
└─────────────────────────────────────┘
```

**Photo:** (84, 430) → (424, 910)
**Map:** (450, 430) → (790, 910)
**Gap:** 26px

---

## Typography

| Element | Font | Size | Weight | Line Height | Max Lines |
|---------|------|------|--------|-------------|-----------|
| **Date** | Just Another Hand | 32px | 400 | - | 1 |
| **Text** | Just Another Hand | 28px | 400 | 1.3 | 3 |

---

## Polaroid Sizes

| Layout | Items | Size |
|--------|-------|------|
| Single | 1 | 420px |
| 2×1 | 2 | 340px |
| 3-item | 3 | 280px (planned) |
| 4-item | 4 | 220px (planned) |

---

## Key Measurements

**Frame Padding:**
- Horizontal: 74px (left + right)
- Vertical: 48px (top + bottom)

**Gaps:**
- Date → Content: 70px
- Content → Text: 10px
- Photo ↔ Map: 26px

**Hard Boundaries:**
- Content MUST stay within (74,48) → (800,1192)
- Photos/Maps MUST fit within Content Box
- Icons MUST avoid Date/Content/Text zones

---

## Vertical Rhythm

```
Y = 0    ─┬─ Page Top
         │
Y = 48   ─┼─ Content Area START
         │  (74px from top)
Y = 100  ─┼─ Date Box (60px)
Y = 160  ─┤
         │  70px gap
Y = 230  ─┼─ Content Box (740px)
         │  [Main visual area]
Y = 970  ─┼─ Content Box END
         │  10px gap
Y = 980  ─┼─ Text Box (160px)
Y = 1140 ─┤
         │
Y = 1192 ─┼─ Content Area END
         │  (48px from bottom)
Y = 1240 ─┴─ Page Bottom
```

---

## Debug Colors

Enable with `_kShowContentBox = true`

- 🔵 **Blue** = Date Box
- 🟢 **Green** = Content Box
- 🟠 **Orange** = Text Box

All with 10% alpha background + 2px border

---

## Constants Reference

```dart
// In layout_constants.dart
static const double pageWidth = 874.0;
static const double pageHeight = 1240.0;
static const double framePaddingHorizontal = 74.0;
static const double framePaddingVertical = 48.0;

static const Rect dateBox = Rect.fromLTWH(307, 100, 242, 60);
static const Rect singleContentBox = Rect.fromLTWH(74, 230, 726, 740);
static const Rect textBox = Rect.fromLTWH(200, 980, 474, 160);

static const double polaroidSizeLarge = 420.0;
static const double polaroidSizeMedium = 340.0;
```

---

**Full spec:** See `a5-layout-coordinate-specification.md`
