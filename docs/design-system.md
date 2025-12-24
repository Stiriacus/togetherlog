# TogetherLog Design System

**Version:** 1.1
**Status:** Authoritative Contract
**Last Updated:** 2024-12-24
**Scope:** Application chrome only (excludes Smart Pages, Flipbook internal UI)

---

## Purpose

This document defines the complete design system for TogetherLog's application UI.

**Core Principle:** The application chrome is a museum wall. Smart Pages are the artwork.

**Philosophy:**
- **Content-first** — Memories are the product, UI is the frame
- **Warm & cozy** — Emotional, calm, human
- **Journal-inspired** — Subtle scrapbook feeling, not decorative
- **Minimal branding** — Brand presence is intentionally quiet

---

## 1. Color System

### 1.1 Core Palette

| Token | HEX | Usage |
|-------|-----|-------|
| `carbonBlack` | `#1D1E20` | Primary text, anchors |
| `darkWalnut` | `#592611` | Primary accent, CTAs |
| `oliveWood` | `#785D3A` | Secondary accents, borders |
| `softApricot` | `#FCDCB5` | Highlights, warm surfaces |
| `antiqueWhite` | `#FAEBD5` | App background, cards |

### 1.2 Functional Roles

**Backgrounds:**
- App background: Antique White
- Cards/sheets: Antique White
- Elevated highlights: Soft Apricot (sparingly)

**Text:**
- Primary: Carbon Black
- Secondary: Olive Wood @ 80%
- Disabled/hint: Olive Wood @ 50%

**Actions:**
- Primary action: Dark Walnut
- Secondary action: Olive Wood
- Hover/pressed overlay: Soft Apricot @ 8–12%

### 1.3 Status Colors (Muted)

| State | Token | HEX | Usage |
|-------|-------|-----|-------|
| Success | `successMuted` | `#6F8F7A` | Processing complete |
| Info | `infoMuted` | `#6F7F8F` | Informational banners |
| Error | `errorMuted` | `#9A5A5A` | Validation, warnings |

**Rules:**
- Never used for large backgrounds
- Icons, borders, small banners only
- Must not visually dominate

### 1.4 Log Type Icons (Accent Colors)

| Log Type | HEX |
|----------|-----|
| Couple | `#B86A7C` |
| Friends | `#6F86A8` |
| Family | `#8A6FA8` |

**Usage:** Icons only. Never backgrounds.

---

## 2. Typography

### 2.1 Font Family

**Primary Typeface:** Inter (Google Fonts)

**This is the only font family permitted.**

**Rationale:**
- Highly readable on Web and Android
- Neutral, professional, modern
- Excellent weight range (400–600)
- Performs well at all sizes
- Does not impose personality

**Explicitly Forbidden:**
- Serif fonts
- Display fonts
- Decorative typography
- Multiple font families

### 2.2 Type Scale

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Display / Hero | 32–36 | SemiBold (600) | 1.4 |
| Screen Title | 22–24 | SemiBold (600) | 1.4 |
| Section Header | 18 | Medium (500) | 1.5 |
| Body Primary | 14–16 | Regular (400) | 1.5–1.6 |
| Body Secondary | 13–14 | Regular (400) | 1.5 |
| Caption / Meta | 12 | Regular (400) | 1.4 |
| Button Label | 14–16 | Medium (500) | 1.0 |

### 2.3 Typography Rules

**Allowed Weights:**
- Regular (400)
- Medium (500)
- SemiBold (600)

**Forbidden Weights:**
- Light, Thin, ExtraBold, Black

**Alignment:**
- Left-aligned text only
- No centered body text
- No justified text
- Centering reserved for very short content (empty states)

**Line Height Philosophy:**
- Body text must breathe
- No tight leading
- No dense paragraphs
- If text feels "efficient", it is wrong

**Emphasis:**
- Adjust spacing, placement, or hierarchy
- Never escalate font weight for emphasis

**Integrity Rule:** If text styling draws attention to itself, it is incorrect.

---

## 3. Spacing System

### 3.1 Base Scale

**8dp base unit** — No arbitrary spacing values allowed.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4 | Icon padding, micro spacing |
| `sm` | 8 | Inline spacing |
| `md` | 16 | Card padding, form fields |
| `lg` | 24 | Section spacing |
| `xl` | 32 | Screen section separation |
| `xxl` | 48 | Major screen breaks |

### 3.2 Spacing Rules

- **No spacing outside this scale**
- Vertical rhythm matters more than horizontal
- Prefer spacing over dividers
- Always use tokens, never hardcoded values

### 3.3 Page Padding

- **Mobile:** 16dp
- **Desktop:** 24–32dp

### 3.4 Content Width (Web)

| Context | Max Width |
|---------|-----------|
| Lists | 960px |
| Forms | 720px |
| Text-heavy screens | 720px |
| Flipbook | 1200px+ (or fluid) |

**Rules:**
- Always center content
- Never edge-to-edge text on desktop
- Mobile ignores max width

---

## 4. Shape & Elevation

### 4.1 Border Radius

| Token | Radius | Usage |
|-------|--------|-------|
| `rSm` | 6 | Buttons, inputs, chips |
| `rMd` | 10 | Cards, icon containers |
| `rLg` | 16 | Sheets, dialogs |
| `rFull` | 999 | Only when explicitly circular |

**Rules:**
- Icon containers → `rMd`
- Cards → `rMd`
- Dialogs → `rLg`
- Never mix radii on one surface

### 4.2 Elevation Levels

| Level | Usage |
|-------|-------|
| `e0` | Background |
| `e1` | Cards |
| `e2` | Icon containers |
| `e3` | Floating action buttons |
| `e4` | Overlays / dialogs |

### 4.3 Shadow System

**All shadows are warm-toned**, derived from Olive Wood.

**Shadow Color:** `rgba(120, 93, 58, 0.18)`

| Elevation | Offset (x,y) | Blur | Spread |
|-----------|--------------|------|--------|
| 1 | 0, 1 | 2 | 0 |
| 2 | 0, 2 | 4 | 0 |
| 4 | 0, 4 | 8 | -1 |
| 6 | 0, 6 | 12 | -2 |

**Rules:**
- Never stack shadows
- No black or gray shadows
- Icon containers must never exceed card elevation visually
- No outlines + shadows together

---

## 5. Iconography

### 5.1 Icon System

**Primary Icon Set:** Material Symbols — Outlined

**This is the only icon family permitted.**

**Rationale:**
- Native alignment with Material 3
- Excellent Flutter + Web support
- Consistent optical sizing
- Large, complete icon library
- Neutral, editorial tone (non-playful)

### 5.2 Icon Style Rules

**Variant:** Outlined only

**Forbidden:**
- Filled
- Rounded
- Sharp
- Custom SVGs
- Emojis as icons

**Consistency:**
- Default stroke weight
- No resizing to "make it feel right"
- Icons must look consistent across the entire app

### 5.3 Icon Sizes

| Size | Value | Usage |
|------|-------|-------|
| Small | 20dp | Inline actions, metadata |
| Standard | 24dp | Default, navigation, buttons |
| Large | 48dp | Empty states (top range) |
| Extra Large | 64dp | Empty states (large variant) |

### 5.4 Icon Colors

| State | Color | Opacity |
|-------|-------|---------|
| Active | Dark Walnut | 100% |
| Inactive | Olive Wood | 70% |
| Disabled | Olive Wood | 40% |

**Rule:** Icons inherit text color by default. No multicolor icons outside Smart Pages.

### 5.5 Icon Usage Philosophy

**Icons MUST:**
- Represent a clear, universal action
- Be immediately recognizable
- Reinforce hierarchy, not compete with text

**Icons MUST NOT:**
- Be decorative
- Replace text labels where clarity suffers
- Be used "because it looks empty"

**If text alone is sufficient, do not add an icon.**

### 5.6 Allowed Contexts

**Primary:**
- Navigation destinations
- Primary actions
- Inline action controls (edit, delete, more)
- Floating action buttons

**Secondary (Limited):**
- Metadata indicators (only if universally understood)

---

## 6. Structural Patterns

### 6.1 Canonical Screen Anatomy

Every TogetherLog screen follows this vertical stack:

1. **Navigation Context** — Side rail establishes global context
2. **Screen Header Zone** — Title + optional primary action (never crowded)
3. **Breathing Space** — Intentional empty space
4. **Primary Content Block** — Lists, forms, pages
5. **Secondary / Supporting Content** — Metadata, hints, secondary actions

**Rule:** If you cannot identify these zones on a screen, the screen is incorrectly structured.

### 6.2 Header Zone Rules

**Purpose:** Orient the user. Nothing else.

**Rules:**
- One primary action maximum
- No stacked buttons
- No dense icon clusters
- Title always has visual dominance

**Psychological effect:** Users feel "settled" before engaging with content.

### 6.3 List Screen Pattern

**Visual Structure:**
- Cards float gently on background
- Clear vertical rhythm
- No hard separators

**Card Content Hierarchy:**
1. Primary label (what this is)
2. Emotional or contextual highlight
3. Metadata (date, count, location)

**Rule:** Metadata must never visually compete with primary content.

### 6.4 Forms & Creation Screens

**Forms should feel supportive, not transactional.**

**Rules:**
- One column only
- Labels above inputs
- Generous spacing
- No inline validation unless critical

**Emotional Goal:** User feels guided, not evaluated.

### 6.5 Icon Container Pattern

**Purpose:** Communicate "This is a tool, not decoration."

**Anatomy:**
- Background: slightly darker than surface
- Radius: `rMd`
- Padding: `xs` → `sm`
- Elevation: `e2`
- Icon centered, never edge-aligned

**Allowed Only For:**
- Primary action buttons
- Inline action icons
- Floating action buttons
- Active navigation item only

**Forbidden everywhere else.**

**Rule:** If you see many icon containers clustered together → misuse.

### 6.6 Navigation Rail Contract

**Layout:**
- Fixed vertical column
- Expanded: ~240–256px
- Collapsed: ~72px
- Content area never overlaps rail

**Visual Rules:**
- Background is a surface, not transparent
- No heavy borders

**Active item:**
- Icon container visible
- Text emphasized

**Inactive items:**
- No container
- Muted icon color

---

## 7. Component Styling

### 7.1 AppBar

- **Background:** Antique White
- **Text/Icons:** Carbon Black
- **Elevation:** 0–1
- **Typography:** Inter
- **Title alignment:** Left-aligned (Auth screen only: centered)

### 7.2 Buttons

**Primary:**
- Background: Dark Walnut
- Text: Antique White
- Radius: `rSm` (6)
- Press overlay: Soft Apricot @ 12%
- Disabled: Olive Wood @ 20% background, 50% text

**Secondary:**
- Border: Olive Wood
- Text: Olive Wood
- Hover: Soft Apricot @ 8%

**Text Button:**
- Text: Dark Walnut
- Hover: underline or Soft Apricot tint

**Floating Action Button:**
- Background: Dark Walnut
- Icon/Text: Antique White
- Extended FAB preferred
- Placement: Bottom-right
- Used only on: Logs List, Entries List

### 7.3 Cards

- **Background:** Antique White
- **Radius:** `rMd` (10)
- **Elevation:** 1–2
- **Tap feedback:** Soft Apricot @ 8%

### 7.4 Inputs

- **Background:** Antique White
- **Border:** Olive Wood @ 30%
- **Focus border:** Dark Walnut
- **Error:** errorMuted
- **Disabled:**
  - Border: Olive Wood @ 20%
  - Text: Olive Wood @ 50%

### 7.5 Chips / Tags

- **Background:** Soft Apricot
- **Text:** Carbon Black
- **Selected:** Dark Walnut background + Antique White text
- **Disabled:** Soft Apricot @ 40%, text Olive Wood @ 50%

### 7.6 Dividers

- **Color:** Olive Wood @ 20%
- **Thickness:** 1dp
- **Spacing:** 8–16dp
- **Functional only. Never decorative.**

---

## 8. Interaction & Motion

### 8.1 Interaction States

**Every interactive component must define:**

| State | Required |
|-------|----------|
| Default | Yes |
| Hover (Web) | Yes |
| Pressed | Yes |
| Disabled | Yes |
| Loading | Yes |

**No exceptions.** If a component lacks states, it is incomplete.

### 8.2 Feedback Hierarchy

**Priority Order:**
1. Press feedback (immediate)
2. Loading feedback
3. Success confirmation
4. Error handling

**Rule:** If the user presses something and nothing happens immediately, the UI is broken.

### 8.3 Motion Principles

**Motion should feel like paper and space, not software tricks.**

**Rules:**
- Motion connects states
- Motion never decorates
- Motion stops as soon as comprehension is achieved
- If motion is noticed, it is already too strong

### 8.4 Timing

| Interaction | Duration |
|-------------|----------|
| Button press | 120ms |
| Hover | 150ms |
| Page transition | 220ms |
| Bottom sheet | 280ms |
| Dialog | 240ms |

### 8.5 Curves

- **Default:** easeOutCubic
- **Enter:** easeOut
- **Exit:** easeIn

**Allowed Motions:**
- Fade + slight translate (dialogs)
- Crossfade (navigation)
- Elevation change (hover/press)

**Forbidden:**
- Bounce
- Springy motion

---

## 9. Loading & Empty States

### 9.1 Loading Philosophy

**Allowed:**
- Skeletons
- Soft placeholders
- Progressive reveal

**Forbidden:**
- Blocking overlays
- Indeterminate spinners without context

**Psychology:** Users tolerate waiting when they understand progress.

### 9.2 Empty States

**Must answer three questions:**
1. Where am I?
2. Why is this empty?
3. What should I do next?

**Tone:**
- Calm
- Reassuring
- Non-marketing
- No humor
- No illustrations unless extremely subtle

---

## 10. Focus & Accessibility

### 10.1 Focus Ring

- **Color:** Dark Walnut
- **Thickness:** 2dp
- **Offset:** 2dp
- **Radius:** Matches component

**Applies to:**
- Buttons
- Inputs
- FAB
- Interactive cards

---

## 11. Platform Adaptation

### 11.1 Web (Primary)

- Wider max-width containers
- Hover states enabled
- More whitespace

### 11.2 Android

- Slightly tighter spacing
- Clear touch targets (min 48dp)
- Muted ripple effects allowed

**Visual identity must remain consistent.**

---

## 12. Forbidden Practices

**The following are explicitly forbidden:**

**Typography:**
- Multiple font families
- Decorative fonts
- Random font size adjustments
- Using typography as decoration
- Inconsistent text styles across screens

**Icons:**
- Mixing icon families
- Mixing outlined and filled styles
- Custom SVG icons
- Emojis as icons
- Using icons to replace clear text labels
- Overloading screens with icons

**Layout:**
- Arbitrary spacing values
- Edge-to-edge text on desktop
- Centered body text
- Justified text

**Visual:**
- Black or gray shadows
- Stacking shadows
- Using status colors for large backgrounds
- Multicolor icons outside Smart Pages

---

## 13. Explicit Exclusions

**This design system does NOT apply to:**

- Smart Page layouts
- Flipbook internal UI
- Emotion-Color-Engine output
- Photo overlays

**Smart Pages are explicitly allowed to clash visually.**

---

## 14. Screen Inventory

### Application Screens (7 Screens)

| Screen | Route | Purpose | Auth Required |
|--------|-------|---------|---------------|
| Auth | `/auth` | Login and signup | No |
| Logs List | `/logs` | View and manage memory logs | Yes |
| Entries List | `/logs/:logId/entries` | View entries within a log | Yes |
| Entry Create | `/logs/:logId/entries/create` | Create new memory entry | Yes |
| Entry Detail | `/entries/:entryId` | View entry details | Yes |
| Entry Edit | `/entries/:entryId/edit` | Modify existing entry | Yes |
| Flipbook Viewer | `/logs/:logId/flipbook` | Immersive page-turn experience | Yes |

### User Journey

```
Auth → Logs List → Entries List → Entry Detail
                 ↓              ↓
              Flipbook    Create/Edit Entry
```

### Global UI Patterns

**AppBar (Standard):**
- Background: Antique White
- Text/Icons: Carbon Black
- Elevation: 0–1
- Title position: Center-left (except Auth: centered)

**Loading State:**
- Position: Center
- Component: CircularProgressIndicator
- Usage: Data fetching, form submission, image loading

**Error State:**
- Position: Center
- Components: Error icon (top) + message (middle) + retry button (bottom)

**Empty State:**
- Position: Center
- Components: Large icon (48-64dp) + "No [items] yet" message + optional CTA
- Tone: Calm, reassuring, non-marketing

**Floating Action Button:**
- Position: Bottom-right
- Style: Extended FAB (icon + label)
- Present on: Logs List, Entries List

---

## 15. Component Library Reference

### Flutter Material Widgets Used

**Input Components:**
- `TextFormField` — Text input (rounded border, icon prefix)
- `DropdownButtonFormField` — Selection (matches text field styling)
- `SwitchListTile` — Boolean toggle with label
- `FilterChip` — Multi-select tags (selected state with checkmark)

**Display Components:**
- `Card` — Container (elevation 1-2, radius rMd)
- `Chip` — Read-only tag display
- `ListTile` — Row item (icon, title, subtitle)
- `Badge` — Status indicator

**Action Components:**
- `FilledButton` — Primary action
- `TextButton` — Secondary action
- `IconButton` — Icon-only action (AppBar, inline)
- `FloatingActionButton.extended` — Primary screen action

**Feedback Components:**
- `CircularProgressIndicator` — Loading (centered, indeterminate)
- `SnackBar` — Toast messages (bottom-positioned)
- `AlertDialog` — Confirmations (title, content, actions)
- `BottomSheet` — Action menus (slide-up panel)

---

## 16. Authority

This document is the **single source of truth** for TogetherLog UI theming.

Any UI change must:
1. Conform to this guide, **or**
2. Explicitly revise this document with version bump

**Violation of this design system constitutes a design defect.**

---

## Appendix: Implementation Reference

**Flutter Theme Files:**
- `app/lib/core/theme/app_theme.dart` — Main theme implementation
- `app/lib/core/theme/app_icons.dart` — Icon mappings
- `app/lib/core/theme/smart_page_theme.dart` — Smart Page color themes (separate system)

**Design Token Classes:**
- `AppColors` — Color palette
- `AppSpacing` — Spacing scale
- `AppRadius` — Border radius tokens
- `AppIconSize` — Icon sizes
- `AppDurations` — Animation timing

**Flutter Routing:**
- `app/lib/core/routing/router.dart` — Route definitions and auth guards

**Status:** Fully implemented and enforced as of v1.1
