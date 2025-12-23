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
  - Warm brown frame (#8B7355) on all layouts
  - 12px border width with 48px inner padding
  - Inner shadow for depth effect
  - Content stays safely inside frame

### Layout Changes
- **Single Full Layout**: 380px Polaroid, top-center aligned
- **Grid 2x2 Layout**: 220px Polaroids, scattered Wrap layout
- **Grid 3x2 Layout**: 190px Polaroids, densely packed

- Photos anchor to top (not centered) for page-filling effect
- Wrap widget replaces GridView for organic scatter
- Text headers minimized to maximize photo coverage
- Expanded widgets allow photos to fill vertical space

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

---

*Last updated: 2025-12-23*
