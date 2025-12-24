# TogetherLog - Recent Changes

## UI Quality Upgrades

### Auth Screens
- Migrated to Material Symbols Outlined icons via AppIcons
- Applied spacing tokens throughout (xs, sm, md, lg, xl, xxl)
- Changed background to Old Lace (#FDF5E6)
- Updated max width from 500px to 720px (form standard)
- Improved tab selector with full-width indicator
- Fixed floating label clipping with proper padding
- Added auth icons: email, lock, lockOpen

### Entry Detail Screen
- Wrapped with AuthenticatedShell for consistent navigation
- Added header zone with back button and edit action
- Reduced photo sizes from grid to 240×240px squares
- Added "window" treatment with borders (never stretching)
- Applied content width constraint (960px max)
- Migrated all icons to Material Symbols
- Updated all spacing to tokens

### Logs & Entries Screens
- Applied structural patterns (header zone, breathing space)
- Content width constraints (960px for lists, 720px for forms)
- Improved loading/error/empty states
- Fixed icon slot width (48px) to prevent layout jitter
- Migrated to Material Symbols icons

## Flipbook Scrapbook Redesign

### Visual Design
- **Created PolaroidPhoto widget**
  - White frame with thick bottom "chin" (40px)
  - Stable random rotation (-6° to +6°) per photo
  - Layered shadows for depth
  - Uses photo URL hash for deterministic randomness

- **Added decorative frame borders**
  - ~~Warm brown frame (#8B7355) on all layouts~~ (replaced)
  - **Classic olive-brown PNG border** (`classic_boarder_olivebrown.png`)
  - Transparent border asset with vintage aesthetic
  - Border properly centered with `Positioned.fill` and `BoxFit.contain`
  - Removed inner shadow (interfered with transparent border)

### Responsive Layout System
- **Flex-based spacing** using `Spacer` widgets for proportional scaling
  - Top spacer: 5% of page height (date padding)
  - Date-to-photo gap: 5%
  - Photo area: 60% (fills middle space)
  - Photo-to-text gap: 5%
  - Bottom spacer: 4% (text padding)
- **Responsive text width**: `FractionallySizedBox` at 65% of page width
  - Maintains proportions across all screen sizes
  - Prevents text from being too wide or too narrow
- All layouts wrapped in `LayoutBuilder` for dynamic sizing

### Typography & Text Layout
- **Handwritten font**: "Just Another Hand" via Google Fonts
  - Applied to both date and description text
  - Authentic scrapbook/journal aesthetic
- **Responsive font sizing**:
  - Scales dynamically: `(containerWidth * 0.035).clamp(14.0, 24.0)`
  - Multiplied by 1.5x for handwritten font readability
  - Date and description use same size for visual consistency
- **Text positioning**:
  - Date centered at top with flex-based padding
  - Description centered at bottom with 4 max lines (up from 2)
  - Location icon centered below description
  - All text center-aligned for scrapbook look
- Padding increased to 64px horizontal, 48px vertical

### Layout Changes
- **Single Full Layout**: 380px Polaroid, centered, date at top, text at bottom
- **Grid 2x2 Layout**: 220px Polaroids, scattered Wrap layout, date at top, text at bottom
- **Grid 3x2 Layout**: 190px Polaroids, densely packed, date at top, text at bottom

- Photos anchor to top-center/top-left for page-filling effect
- Wrap widget replaces GridView for organic scatter
- **Layout hierarchy**: Date (top) → Photos (middle) → Description + Location (bottom)
- Expanded widgets with flex values for proportional space distribution

### Animation
- Removed `page_flip` package dependency
- Replaced 3D page-flip with native PageView
- Smooth horizontal slide animation (300ms, easeInOut)
- Previous/Next buttons with proper disabled states
- Integrated with existing page tracking provider

## Theme Updates
- Background color changed: #FAEBD5 → #FDF5E6 (Old Lace)
- Fixed 10 const constructor warnings in app_theme.dart
- All radius references use new tokens (rSm, rMd, rLg, rFull)

## Icon System
- Added location icons: location, editLocation
- Added media icons: brokenImage, autoAwesome
- Added auth icons: email, lock, lockOpen
- All using Material Symbols Outlined variant

## Bug Fixes
- Fixed AppRadius migration errors across multiple files
- Removed unused import in authenticated_shell.dart
- Fixed floating label clipping in auth forms
- Proper tab indicator sizing with full-width pills

## Build Status
- ✅ Flutter analyze: No issues found
- ✅ Web build successful (15.8s compilation)
- ✅ Icon tree-shaking: 99.5% size reduction
- ✅ All changes committed and pushed

## Architecture Documentation

### New Documentation Files
- **`ARCHITECTURE_IMPROVEMENTS.md`**
  - Tracks architectural improvement proposals
  - Documents backend-authoritative Smart Page layout refactor proposal
  - Includes implementation plan for V2 consideration

## Recent Updates (2024-12-24)

### Flipbook Hand-Drawn Map Integration
- **Added PolaroidMap widget** for displaying locations in scrapbook style
  - Uses flutter_map with Stamen Watercolor tiles for hand-drawn aesthetic
  - Rendered in Polaroid frame matching photo style
  - Location name displayed as handwritten caption in "Just Another Hand" font
  - Stable random rotation (-6° to +6°) based on location name hash
  - Non-interactive map with centered pin marker
- **Integrated map into single_full_layout**
  - Map displays as additional Polaroid card alongside photo
  - Shows both photo + map when entry has location data
  - Map appears in last position (as designed)
  - Removed location icon/text from bottom section (map shows it)
- **Dependencies added**: flutter_map ^6.0.0, latlong2 ^0.9.0

### Location Editor Bug Fix
- **Fixed location data not persisting** on entry create/edit
  - Backend expects flat fields (location_lat, location_lng, location_display_name)
  - Frontend was sending nested object
  - Updated entries_repository.dart to flatten location data before API calls
  - Location now saves correctly in both create and update operations

### Flipbook Responsive Typography & Layout
- Implemented fully responsive flipbook layouts across all three layout types
- Added "Just Another Hand" handwritten font for authentic scrapbook aesthetic
- Migrated to flex-based spacing system for consistent scaling across screen sizes
- Centered text layout with responsive width constraints (65% of page width)
- Increased description text from 2 to 4 max lines
- Fixed PNG border rendering with proper centering and aspect ratio preservation

---

*Last updated: 2024-12-24*
