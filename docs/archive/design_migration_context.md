# TogetherLog — Design Migration Context

**Created:** 2025-12-12
**Updated:** 2025-12-12
**Purpose:** Consolidated design understanding for migration and implementation guidance
**Role:** Senior Product Designer / UX Architect / Design Systems Engineer
**Status:** Reference Document (with V1.1 Gap Resolution applied)
**Theme Version:** V1.1

---

## 1. Document Authority Hierarchy

| Document | Authority | Purpose |
|----------|-----------|---------|
| `design_theme_v1.md` | **Authoritative Contract** | Defines visual identity, color system, typography, component styling |
| `design_spec.md` | **Structural Reference** | Documents current screen inventory, components, navigation |
| `v1Spez.md` | **Feature Specification** | Defines MVP scope and functional requirements |
| `architecture.md` | **Technical Constraints** | Establishes backend-authoritative patterns |

**Decision Rule:** If a design question is not explicitly addressed in these documents, it is **out of scope** for V1 and must not be invented.

---

## 2. Product Understanding

### 2.1 Core Product Identity

TogetherLog is a **memory preservation platform** for couples and close groups, manifested as an interactive digital flipbook.

**Product Goals:**
- Beautiful to look at
- Simple to capture
- Respectful of privacy
- Easy to self-host

**Mental Model:** A personal, chronological scrapbook that auto-designs itself.

### 2.2 Target Users

- Couples documenting shared moments
- Friends preserving group memories
- Families capturing milestones

**Key Insight:** Users are emotionally invested in their content. The UI must facilitate, not distract.

### 2.3 V1 Scope Boundaries

**In Scope:**
- Online-only experience
- Single-owner logs (no collaboration)
- Backend-computed Smart Pages
- 3D page-turn flipbook viewer
- Email/password and Google OAuth authentication
- Predefined tag system (19 tags)
- Location handling (EXIF extraction + manual override)

**Explicitly Out of Scope (V1):**
- Offline mode
- Map view
- Story slideshow
- Multi-user editing
- Dark mode
- AI-enhanced Smart Pages
- PDF export
- Heatmaps
- Mobile widgets

---

## 3. Architectural Constraints Affecting Design

### 3.1 Backend-Authoritative Pattern

**Critical Constraint:** The Flutter client does NOT compute Smart Page logic.

| Computed on Backend | Rendered by Client |
|--------------------|--------------------|
| `page_layout_type` | Layout widget selection |
| `color_theme` | Theme application |
| `sprinkles[]` | Decorative overlays |
| Thumbnail generation | Image display |
| Dominant colors | (Future use) |
| EXIF extraction | Date/location display |
| Reverse geocoding | Location display |

**Design Implication:** UI cannot make assumptions about page appearance. The client receives pre-computed definitions and renders them verbatim.

### 3.2 Data Flow Impact on UX

1. User uploads photos
2. Backend processes asynchronously (EXIF, thumbnails, Smart Page computation)
3. Entry initially shows "Processing" state
4. Client polls/refreshes to get computed result
5. Flipbook renders final Smart Page

**UX Consideration:** There is an inherent delay between entry creation and Smart Page availability. The design must accommodate loading/processing states gracefully.

### 3.3 Platform Hierarchy

| Platform | Priority | Considerations |
|----------|----------|----------------|
| Flutter Web | Primary | Wider layouts, hover states, mouse/keyboard navigation |
| Flutter Android | Secondary | Touch-optimized, tighter spacing, swipe gestures |

**Constraint:** Visual identity must remain consistent across platforms. Only interaction patterns adapt.

---

## 4. Design Philosophy Summary

### 4.1 Core Principles (from design_theme_v1.md)

1. **Content-first:** Memories are the product; UI is the frame
2. **Warm & cozy:** Emotional, calm, human
3. **Journal-inspired:** Subtle scrapbook feeling, not decorative
4. **Minimal branding:** Brand presence is intentionally quiet
5. **Acceptable contrast:** Smart Pages may clash; this is allowed

### 4.2 The "Museum Wall" Mental Model

> The application chrome is a museum wall.
> Smart Pages are the artwork.

**Implication:** Application chrome (AppBar, forms, lists, navigation) must be visually neutral. Smart Pages are the visual focus and may use any color theme without concern for harmony with the shell.

### 4.3 Visual Neutrality Zones

| Zone | Treatment |
|------|-----------|
| AppBar | Standard elevation, no custom backgrounds (except Flipbook) |
| Form containers | White/light gray (now Antique White per theme) |
| Cards (list views) | Minimal shadow, neutral borders |
| Navigation controls | Semi-transparent, icon-only where possible |
| Buttons | Use primary color sparingly |
| Empty states | Grayscale icons, muted text |

### 4.4 Photo-Dominant Zones

| Zone | Treatment |
|------|-----------|
| Flipbook pages | Full bleed to content edges |
| Entry card thumbnails | No borders, natural aspect ratio |
| Photo grids | Minimal gaps, rounded corners only |

---

## 5. Design System Reference

### 5.1 Color Palette (Authoritative)

#### Core Palette

| Token | HEX | Role |
|-------|-----|------|
| carbonBlack | #1D1E20 | Primary text, anchors |
| darkWalnut | #592611 | Primary accent, CTAs |
| oliveWood | #785D3A | Secondary accents, borders |
| softApricot | #FCDCB5 | Highlights, warm surfaces |
| antiqueWhite | #FAEBD5 | App background, cards |

#### Status Colors (V1.1 Addition)

| Token | HEX | Usage |
|-------|-----|-------|
| successMuted | #6F8F7A | Processing complete, Smart Page ready |
| infoMuted | #6F7F8F | Informational banners, notices |
| errorMuted | #9A5A5A | Validation errors, destructive warnings |

#### Log Type Icon Colors (V1.1 Addition)

| Log Type | HEX | Description |
|----------|-----|-------------|
| Couple | #B86A7C | Muted rose |
| Friends | #6F86A8 | Muted blue |
| Family | #8A6FA8 | Muted purple |

**Functional Mapping:**
- App background: antiqueWhite
- Primary text: carbonBlack
- Secondary text: oliveWood (80% opacity)
- Primary action: darkWalnut
- Secondary action: oliveWood
- Warm highlight: softApricot

### 5.2 Typography (Authoritative)

| Role | Font | Size | Weight |
|------|------|------|--------|
| Display/Hero | Playfair Display | 32-36 | SemiBold |
| Screen Title | Playfair Display | 22-24 | SemiBold |
| Section Header | Inter | 18 | Medium |
| Body Primary | Inter | 14-16 | Regular |
| Body Secondary | Inter | 13-14 | Regular |
| Caption/Meta | Inter | 12 | Regular |
| Button Label | Inter | 14-16 | Medium |

**Note:** AppBar uses Inter, not Playfair Display.

### 5.3 Spacing System (Authoritative)

Base unit: 8dp

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing |
| sm | 8px | Component internal |
| md | 16px | Section padding |
| lg | 24px | Section separation |
| xl | 32px | Major divisions |

Page padding: 16dp (mobile), 24-32dp (desktop)

### 5.4 Shape System (Authoritative)

| Element | Border Radius |
|---------|---------------|
| Buttons | 8px |
| Inputs | 8px |
| Cards | 12px |
| Thumbnails | 12-16px |
| Chips | 16px (pill) |

### 5.5 Elevation Rules (Authoritative)

| Element | Elevation |
|---------|-----------|
| AppBar | 0-1 |
| Card | 1-2 |
| Dialog | 4 |
| BottomSheet | 6 |

#### Shadow Definition (V1.1 Addition)

**Base shadow color:** `rgba(120, 93, 58, 0.18)` (Olive Wood @ 18% opacity)

| Elevation | Offset (x,y) | Blur | Spread |
|-----------|--------------|------|--------|
| 1 | 0, 1 | 2 | 0 |
| 2 | 0, 2 | 4 | 0 |
| 4 | 0, 4 | 8 | -1 |
| 6 | 0, 6 | 12 | -2 |

### 5.6 Interaction States (V1.1 Addition)

| State | Overlay Color | Alpha |
|-------|---------------|-------|
| Hover | Soft Apricot | 0.08 |
| Pressed | Soft Apricot | 0.12 |
| Focus | Soft Apricot | 0.10 |

### 5.7 Icon Specifications (V1.1 Addition)

| Context | Size |
|---------|------|
| Default | 24dp |
| Small (inline) | 20dp |
| Large (empty state) | 48-64dp |

**Color Rules:**
- Active: darkWalnut
- Inactive: oliveWood @ 70%
- Disabled: oliveWood @ 40%
- Empty state: oliveWood @ 40%

---

## 6. Screen Inventory (Current State)

### 6.1 MVP Screens (7 Total)

| # | Screen | Route | AppBar | FAB |
|---|--------|-------|--------|-----|
| 1 | Auth | `/auth` | No | No |
| 2 | Logs List | `/logs` | Yes | Yes |
| 3 | Entries List | `/logs/:logId/entries` | Yes | Yes |
| 4 | Entry Create | `/logs/:logId/entries/create` | Yes | No |
| 5 | Entry Detail | `/entries/:entryId` | Yes | No |
| 6 | Entry Edit | `/entries/:entryId/edit` | Yes | No |
| 7 | Flipbook Viewer | `/logs/:logId/flipbook` | Yes (dark) | No |

### 6.2 Navigation Architecture

```
/auth                           (unauthenticated)
/logs                           (authenticated home)
  +-- /logs/:logId/entries      (log context)
        +-- /logs/:logId/entries/create
        +-- /logs/:logId/flipbook
/entries/:entryId               (entry context)
  +-- /entries/:entryId/edit
```

**Pattern:** Hierarchical navigation (AppBar-based), no bottom tabs.

**Auth Guards:**
- Unauthenticated -> Redirect to `/auth`
- Authenticated on `/auth` -> Redirect to `/logs`

---

## 7. Component Styling (Current State vs. Theme Contract)

### 7.1 AppBar

| Attribute | Current (design_spec) | Theme Contract (design_theme_v1) |
|-----------|----------------------|----------------------------------|
| Background | Standard Material | antiqueWhite |
| Text/Icons | Default | carbonBlack |
| Elevation | Standard | 0-1 (minimal) |
| Font | Default | Inter |

### 7.2 Buttons

| Type | Theme Contract |
|------|----------------|
| Primary (Filled) | BG: darkWalnut, Text: antiqueWhite, Radius: 8 |
| Secondary (Outlined) | Border: oliveWood, Text: oliveWood, Hover: softApricot |
| Text | Text: darkWalnut, Hover: underline or warm tint |

### 7.3 FAB

| Attribute | Theme Contract |
|-----------|----------------|
| Background | darkWalnut |
| Icon/Text | antiqueWhite |
| Style | Extended preferred |
| Elevation | Slight (for discoverability) |

### 7.4 Cards

| Attribute | Theme Contract |
|-----------|----------------|
| Background | antiqueWhite |
| Radius | 12px |
| Shadow | Minimal, warm-toned |
| Borders | No decorative borders |

### 7.5 Inputs

| Attribute | Theme Contract |
|-----------|----------------|
| Background | antiqueWhite |
| Border | oliveWood (30%) |
| Focus Border | darkWalnut |
| Error State | Muted red |
| Radius | 8px |

### 7.6 Chips/Tags

| State | Theme Contract |
|-------|----------------|
| Default | BG: softApricot, Text: carbonBlack |
| Selected | BG: darkWalnut, Text: antiqueWhite |

---

## 8. Smart Page Isolation Principle

### 8.1 Boundary Definition

Smart Page theming applies **exclusively** within:
- `FlipbookViewer` -> `SmartPageRenderer`

Smart Page themes **never** bleed into:
- AppBar
- Forms
- List screens
- Navigation controls
- Dialogs/sheets

### 8.2 Available Smart Page Themes

| Theme ID | Visual Direction |
|----------|------------------|
| warm_red | Romantic, passion |
| earth_green | Nature, outdoors |
| ocean_blue | Water, calm |
| deep_purple | Nightlife, mystery |
| warm_earth | Food, comfort |
| soft_rose | Travel, adventure |
| neutral | Default fallback |

### 8.3 Flipbook Viewer Exception

The Flipbook Viewer uses a **dark gray background** for the application chrome. This is intentional:
1. Creates visual separation from the "book" content
2. Avoids color clashing with any Smart Page theme
3. Focuses attention on the memory content

This is the **only** screen where the application chrome deviates from the warm/light theme.

---

## 9. Motion & Interaction Guidelines

### 9.1 Principles

- Soft, organic, never mechanical
- Emotionally supportive, not attention-seeking

### 9.2 Animation Timing (V1.1 Addition)

| Interaction | Duration |
|-------------|----------|
| Button press | 120ms |
| Hover transition | 150ms |
| Page transition | 220ms |
| Bottom sheet enter | 280ms |
| Dialog enter | 240ms |

### 9.3 Animation Curves (V1.1 Addition)

| Context | Curve |
|---------|-------|
| Default | easeOutCubic |
| Enter animations | easeOut |
| Exit animations | easeIn |

### 9.4 Animation Patterns

| Context | Animation |
|---------|-----------|
| Page transitions | Fade + slight vertical motion |
| Buttons | Micro-scale + color fade |
| Lists | Gentle fade-in |
| Bottom sheets | Slow, smooth rise |
| Flipbook page-turn | **Excluded** (isolated system) |

---

## 10. Platform Adaptation Rules

### 10.1 Web (Primary)

- Wider max-width containers
- Hover states enabled
- More white space
- Mouse/keyboard navigation

### 10.2 Android (Secondary)

- Slightly tighter spacing
- Clear touch targets (minimum 48dp)
- Muted ripple effects allowed
- Swipe gestures for navigation

**Constraint:** Visual identity (colors, typography, shapes) must remain consistent.

---

## 11. Out of Scope Items

The following design decisions are **not defined** in the authoritative documents and must not be invented:

1. Dark mode styling
2. Tablet-specific layouts
3. Smart Page internal layout rules (computed by backend)
4. Sprinkle positioning logic (computed by backend)
5. Map view UI
6. Story slideshow UI
7. Multi-user collaboration UI
8. Export/PDF UI
9. Settings screen (not in MVP)
10. Notification patterns
11. Onboarding flows
12. Empty log gallery states
13. Search/filter UI patterns
14. Accessibility-specific adaptations beyond standard Flutter defaults

If any of these are needed, they require explicit specification before design work.

---

## 12. Migration Checklist Reference

When migrating to the theme contract, the following elements require attention:

### 12.1 Global Changes

- [ ] App background color -> antiqueWhite (#FAEBD5)
- [ ] Primary text color -> carbonBlack (#1D1E20)
- [ ] Secondary text color -> oliveWood (#785D3A) at 80%
- [ ] Add Google Fonts: Playfair Display, Inter
- [ ] Update ThemeData with custom color scheme
- [ ] Update typography theme with custom text styles
- [ ] Add status colors: successMuted, infoMuted, errorMuted (V1.1)
- [ ] Add log type colors: Couple, Friends, Family (V1.1)

### 12.2 Component Updates

- [ ] AppBar -> antiqueWhite background, carbonBlack icons/text, left-aligned title
- [ ] FilledButton -> darkWalnut background, antiqueWhite text
- [ ] OutlinedButton -> oliveWood border/text
- [ ] TextButton -> darkWalnut text
- [ ] FAB -> darkWalnut background, antiqueWhite icon/text
- [ ] Card -> antiqueWhite background, 12px radius, warm shadow (oliveWood @ 18%)
- [ ] TextField/Input -> antiqueWhite fill, oliveWood border (30%), darkWalnut focus
- [ ] FilterChip -> softApricot default, darkWalnut selected
- [ ] Divider -> oliveWood @ 20%, 1dp thickness (V1.1)

### 12.3 Interaction States (V1.1)

- [ ] Hover overlay -> softApricot @ 0.08
- [ ] Pressed overlay -> softApricot @ 0.12
- [ ] Focus overlay -> softApricot @ 0.10
- [ ] Focus ring -> darkWalnut, 2dp, 2dp offset

### 12.4 Disabled States (V1.1)

- [ ] Disabled button -> oliveWood @ 20% bg, oliveWood @ 50% text
- [ ] Disabled input -> antiqueWhite bg, oliveWood @ 20% border, oliveWood @ 50% text
- [ ] Disabled chip -> softApricot @ 40% bg, oliveWood @ 50% text

### 12.5 Screen-Specific

- [ ] Auth screen -> Playfair Display for title/headline, centered title
- [ ] Empty states -> Playfair Display for headline, oliveWood @ 40% icon
- [ ] Flipbook AppBar -> Retain dark styling (exception)
- [ ] Photo placeholder -> Solid antiqueWhite, no shimmer

---

## 13. Design Decision Log

| Date | Decision | Rationale | Authority |
|------|----------|-----------|-----------|
| - | Light theme only | V1 scope limitation | v1Spez.md |
| - | No bottom navigation | Reinforces hierarchical mental model | design_spec.md |
| - | Smart Pages isolated | Backend-authoritative architecture | architecture.md |
| - | Flipbook dark chrome | Visual separation from content | design_spec.md |
| - | Warm color palette | Journal-inspired, cozy feeling | design_theme_v1.md |
| - | Playfair + Inter fonts | Editorial warmth + readability | design_theme_v1.md |
| 2025-12-12 | Status colors defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Shadow values defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Interaction opacities defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Disabled states defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Icon specifications defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Log type colors defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Animation timing defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Focus ring defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | Divider styling defined | Gap resolution for V1.1 | design_theme_v1.md (V1.1) |
| 2025-12-12 | AppBar left-aligned | Implementation clarification | design_theme_v1.md (V1.1) |
| 2025-12-12 | No shimmer placeholders | Implementation clarification | design_theme_v1.md (V1.1) |

---

## 14. Summary

This document consolidates the design understanding for TogetherLog V1.1:

1. **Product:** Memory preservation flipbook for couples/groups
2. **Architecture:** Backend-authoritative Smart Pages, lean Flutter client
3. **Philosophy:** Content-first, warm/cozy, minimal branding
4. **Theme:** Warm palette (walnut, apricot, olive), Playfair + Inter typography
5. **Screens:** 7 MVP screens with hierarchical navigation
6. **Isolation:** Smart Page themes never bleed into application chrome
7. **Constraints:** Online-only, light mode only, no invented features
8. **V1.1 Additions:** Status colors, shadows, interaction states, disabled states, icons, animations, focus rings, dividers fully specified

**Status:** All previously identified gaps have been resolved in design_theme_v1.md (V1.1).

---

*This document is a read-only reference synthesizing existing specifications. V1.1 gap resolutions have been incorporated.*
