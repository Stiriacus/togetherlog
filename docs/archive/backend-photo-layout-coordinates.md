# Backend-Authoritative Photo Layout Coordinates

**Created:** 2024-12-24
**Status:** Proposed
**Priority:** High (Architecture Violation)
**Effort:** Medium-Large
**Target:** V2 or V1.1

---

## Problem

**Architecture Violation:** Flutter client is computing Smart Page layout details, violating the backend-authoritative principle.

**Currently backend computes:**
- ✅ Layout type (`single_full`, `grid_2x2`, `grid_3x2`)
- ✅ Color theme (emotion-based)
- ✅ Sprinkles (decorative icons)

**Currently Flutter computes (WRONG):**
- ❌ Photo sizes (380px, 220px, 190px - hardcoded)
- ❌ Spacing between photos (20px, 16px)
- ❌ Content padding (64px)
- ❌ Photo positioning logic (Wrap layout)
- ❌ Polaroid rotation angles (deterministic but client-side)

**Files affected:**
- `app/lib/features/flipbook/widgets/layouts/single_full_layout.dart`
- `app/lib/features/flipbook/widgets/layouts/grid_2x2_layout.dart`
- `app/lib/features/flipbook/widgets/layouts/grid_3x2_layout.dart`

---

## Why This Matters

1. **Architectural Consistency** — Backend should own ALL Smart Page logic
2. **Photo Optimization** — Backend can analyze EXIF and choose optimal sizes for portrait/landscape/square photos
3. **Cross-Platform Consistency** — Same exact layout on web/mobile/tablet
4. **Future Flexibility** — Add new layouts without Flutter code changes

---

## Proposed Solution

**Backend computes exact pixel positions and sizes for each photo.**

### New Database Field

**Table:** `entries`
**New Column:** `layout_data JSONB`

**Structure:**
```json
{
  "photos": [
    {
      "photoId": "uuid",
      "x": 120,
      "y": 80,
      "width": 380,
      "height": 420,
      "rotation": -3.5
    }
  ],
  "textBlock": {
    "x": 64,
    "y": 600,
    "maxWidth": 672
  },
  "borderPadding": 64
}
```

### Backend Changes

**File:** `backend/supabase/functions/compute-smart-page/index.ts`

**Add function:**
```typescript
function computePhotoLayout(
  photos: Photo[],
  layoutType: LayoutType,
  pageWidth: number = 800,    // DIN A5 width
  pageHeight: number = 1142   // DIN A5 height (0.7 ratio)
): LayoutData {
  // 1. Analyze photo orientations from EXIF/dimensions
  // 2. Select optimal Polaroid sizes
  // 3. Calculate absolute positions
  // 4. Generate rotation angles (seeded by photo ID)
  // 5. Return structured layout data
}
```

**Integration:**
- Call after selecting layout type
- Store result in `entries.layout_data`
- Return to client

### Frontend Changes

**File:** `app/lib/data/models/entry.dart`
- Add `layoutData` field (parsed from JSONB)

**Files:** `app/lib/features/flipbook/widgets/layouts/*.dart`

**New rendering logic:**
```dart
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

**Remove:**
- Hardcoded sizes (380px, 220px, 190px)
- Wrap widgets
- Client-side rotation computation
- Spacing logic

---

## Implementation Phases

### Phase 1: Database Schema
**File:** `backend/supabase/migrations/00X_add_layout_data.sql`

```sql
ALTER TABLE entries ADD COLUMN layout_data JSONB;
```

### Phase 2: Backend Computation
**File:** `backend/supabase/functions/compute-smart-page/index.ts`
- Implement `computePhotoLayout()`
- Integrate with existing Smart Pages Engine
- Store in `layout_data` column

### Phase 3: Frontend Refactor
**Files:**
- `app/lib/data/models/entry.dart`
- `app/lib/features/flipbook/widgets/layouts/*.dart`

Replace hardcoded layout logic with coordinate-based rendering.

### Phase 4: Migration
**Backfill existing entries:**

```sql
UPDATE entries SET is_processed = false WHERE layout_data IS NULL;
```

Re-run Smart Pages Engine for all entries.

---

## Testing Requirements

- [ ] Backend computes correct positions for single_full layout
- [ ] Backend computes correct positions for grid_2x2 layout
- [ ] Backend computes correct positions for grid_3x3 layout
- [ ] Portrait photos get optimal sizing
- [ ] Landscape photos get optimal sizing
- [ ] Square photos get optimal sizing
- [ ] Visual regression: old vs new layouts match
- [ ] Performance: entry creation not slowed down
- [ ] Migration: existing entries render correctly
- [ ] Cross-platform: same layout on Web and Android

---

## Benefits

✅ **Architectural Purity** — True backend-authoritative
✅ **Photo Optimization** — Smarter sizing based on EXIF orientation
✅ **Maintainability** — Layout logic centralized in backend
✅ **Flexibility** — Add new layouts without Flutter deploys
✅ **Consistency** — Exact same rendering everywhere

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Backend latency | Cache layout_data, compute asynchronously |
| Migration breaks entries | Thorough testing, gradual rollout |
| Increased backend complexity | Clear docs, unit tests |
| Layout iteration slower | Backend iteration is actually faster (no Flutter rebuild) |

---

## Decision Needed

- [ ] Implement in V1.1 (before launch)
- [ ] Defer to V2 (post-launch refactor)
- [ ] Defer to V1.5 (between major releases)
- [ ] Reject (keep current approach)

**Rationale for deferral:**
- Current approach works functionally
- Non-critical violation (only affects layout flexibility)
- Can be refactored later without breaking changes
- V1 launch should prioritize stability over architectural purity

**Rationale for V1.1:**
- Fix architecture violation early
- Enable better photo orientation handling
- Easier to migrate now than later
- Sets correct foundation for V2 features
