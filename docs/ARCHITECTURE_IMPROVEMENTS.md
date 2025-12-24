# TogetherLog - Architecture Improvements & Refactor Proposals

This document tracks architectural improvements and refactoring proposals for future implementation.

---

## 🔴 HIGH PRIORITY: Backend-Authoritative Smart Page Layout

**Status**: Proposed
**Priority**: High (Architectural Violation)
**Effort**: Medium-Large
**Target**: V2 or V1.1

### Problem Statement

**Current Architecture Violation**: The Smart Pages system violates the backend-authoritative principle defined in `CLAUDE.md`.

Currently, the backend computes:
- ✅ Layout type (`single_full`, `grid_2x2`, `grid_3x2`)
- ✅ Color theme (emotion-based)
- ✅ Sprinkles (decorative icons)

But **Flutter is computing** (client-side):
- ❌ Photo sizes (380px, 220px, 190px - hardcoded in layouts)
- ❌ Spacing between photos (20px, 16px)
- ❌ Content padding (64px)
- ❌ Photo positioning logic (Wrap layout behavior)
- ❌ Polaroid rotation angles (deterministic but client-computed)

**Violation**: *"Smart Page computation (layout types, color themes, sprinkles) is server-side only"*

### Why This Matters

1. **Architectural Consistency**: Backend should own all Smart Page logic
2. **Photo Orientation Optimization**: Backend can analyze EXIF data and choose optimal sizes
   - Landscape photos → wider Polaroid frames
   - Portrait photos → taller Polaroid frames
   - Square photos → current 1:1 ratio
3. **Fixed Aspect Ratio**: DIN A5 (0.7 ratio) never changes, making backend computation predictable
4. **Cross-Platform Consistency**: Same layout on web/mobile/tablet
5. **Future Flexibility**: Can add complex layouts without Flutter code changes

### Proposed Solution

#### Option A: Explicit Photo Coordinates (Recommended)

Backend computes exact pixel positions and sizes for each photo:

```typescript
// Backend Edge Function: compute-smart-page
interface SmartPageLayoutData {
  pageLayoutType: 'single_full' | 'grid_2x2' | 'grid_3x2';
  photos: Array<{
    photoId: string;
    x: number;           // Absolute position from left (px)
    y: number;           // Absolute position from top (px)
    width: number;       // Polaroid width (px)
    height: number;      // Polaroid height (px)
    rotation: number;    // Rotation angle in degrees (-6 to +6)
  }>;
  textBlock: {
    x: number;
    y: number;
    maxWidth: number;
  };
  borderPadding: number;  // Inner padding for border
}
```

**Backend responsibilities:**
- Analyze photo orientations from EXIF data
- Compute optimal Polaroid sizes based on:
  - Layout type (single/grid)
  - Photo aspect ratio (portrait/landscape/square)
  - Available space
- Calculate absolute positions
- Generate deterministic rotation angles

**Flutter responsibilities:**
- Render photos at exact coordinates
- No layout decisions, just positioning

#### Option B: Smart Layout Rules

Backend selects photo size classes, Flutter interprets:

```typescript
interface PhotoLayoutRule {
  photoId: string;
  orientation: 'portrait' | 'landscape' | 'square';
  sizeClass: 'large' | 'medium' | 'small';
  position: 'top-center' | 'grid-slot-1' | 'grid-slot-2';
  rotation: number;
}
```

**Pros**: Less prescriptive, allows some Flutter flexibility
**Cons**: Still requires client-side interpretation logic

#### Option C: Hybrid (Minimal Change)

Backend computes size classes only:

```typescript
interface PhotoSizing {
  photoId: string;
  maxWidth: number;
  maxHeight: number;
  rotation: number;
}
```

**Pros**: Smaller backend change
**Cons**: Flutter still handles positioning logic

### Implementation Plan

#### Phase 1: Database Schema Update

**File**: `backend/supabase/migrations/00X_add_layout_data.sql`

```sql
-- Add layout_data column to entries table
ALTER TABLE entries ADD COLUMN layout_data JSONB;

-- Update is_processed check to validate layout_data
-- (existing field, just ensure compute-smart-page populates it)
```

#### Phase 2: Backend Edge Function

**File**: `backend/supabase/functions/compute-smart-page/index.ts`

Add photo layout computation logic:

```typescript
function computePhotoLayout(
  photos: Photo[],
  layoutType: LayoutType,
  pageWidth: number = 800,  // DIN A5 width reference
  pageHeight: number = 1142  // DIN A5 height (0.7 ratio)
): LayoutData {
  // 1. Analyze photo orientations from EXIF/dimensions
  // 2. Select optimal Polaroid sizes based on layout type
  // 3. Calculate absolute positions
  // 4. Generate rotation angles (seeded by photo ID)
  // 5. Return structured layout data
}
```

Update the Smart Pages Engine to:
1. Call `computePhotoLayout()` after selecting layout type
2. Store result in `entries.layout_data` JSONB column
3. Return layout data to client

#### Phase 3: Frontend Refactor

**Files to Update**:
- `app/lib/data/models/entry.dart` - Add `layoutData` field
- `app/lib/features/flipbook/widgets/layouts/*.dart` - Simplify to use coordinates

**New Layout Logic**:
```dart
// Instead of hardcoded sizes and Wrap layouts:
Stack(
  children: entry.layoutData.photos.map((photoLayout) {
    return Positioned(
      left: photoLayout.x,
      top: photoLayout.y,
      child: Transform.rotate(
        angle: photoLayout.rotation * (pi / 180),
        child: PolaroidPhoto(
          photoUrl: getPhotoById(photoLayout.photoId).url,
          width: photoLayout.width,
          height: photoLayout.height,
        ),
      ),
    );
  }).toList(),
)
```

**Remove**:
- Hardcoded sizes (380px, 220px, 190px)
- Wrap widgets and spacing logic
- Client-side rotation computation

#### Phase 4: Migration & Backfill

**Requirement**: Existing entries need layout_data computed

```sql
-- Trigger recomputation for existing entries
UPDATE entries SET is_processed = false WHERE layout_data IS NULL;
```

Then re-run Smart Pages Engine for all entries.

### Testing Requirements

1. **Backend unit tests**: Photo size calculation logic
2. **Visual regression**: Compare old vs new layouts (should be identical)
3. **Orientation tests**: Verify portrait/landscape/square handling
4. **Performance**: Ensure backend computation doesn't slow down entry creation
5. **Migration**: Test existing entries render correctly

### Benefits Summary

✅ **Architectural Purity**: True backend-authoritative
✅ **Photo Optimization**: Smarter sizing based on orientation
✅ **Maintainability**: Layout logic centralized in backend
✅ **Flexibility**: Easy to add new layout types
✅ **Consistency**: Same rendering across all platforms

### Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Backend computation adds latency | Cache layout_data, compute asynchronously |
| Migration breaks existing entries | Thorough testing, gradual rollout |
| Increased backend complexity | Clear documentation, unit tests |
| Harder to iterate on layouts | Backend has faster iteration cycle than deploys |

### Decision

- [ ] **Implement in V1.1** (before launch)
- [ ] **Defer to V2** (post-launch refactor)
- [ ] **Implement as V1.5** (between milestones)
- [ ] **Rejected** (keep current approach)

**Decision maker**: _[To be decided]_
**Decision date**: _[Pending]_

---

## Future Improvement Proposals

(Add more proposals here as they arise)

---

*Last updated: 2024-12-24*
