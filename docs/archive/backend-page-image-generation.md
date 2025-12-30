# Backend Page Image Generation

**Status:** Planned for future implementation
**Created:** 2025-12-24
**Priority:** Enhancement (Post-V1)

## Overview

Generate flipbook pages as server-rendered images instead of client-side widget rendering. This provides perfect scaling consistency across all devices and simplifies client rendering logic.

## Motivation

### Problems Solved
1. **Scaling Consistency** - Identical rendering on all screen sizes
2. **Simplified Client** - No complex layout logic, just display image
3. **Perfect Determinism** - Same entry = same pixels, always
4. **Reduced Client Complexity** - Single image vs. multiple widgets (photos, text, frame, sprinkles)

### Trade-offs Accepted
- No interactivity on flipbook pages (acceptable - read-only view)
- Larger storage footprint (acceptable - already storing photos)
- Image regeneration on edits (acceptable - infrequent operation)

## Current Implementation (V1)

**Client-side rendering:**
- Flutter widgets render page layout
- Photos, frame, text, sprinkles composed in Stack
- Transform.scale for proportional scaling
- Fixed baseline: 800×1142px (DIN A5)

## Proposed Implementation

### Architecture

```
Entry Updated → Trigger Worker → Generate 800×1142 PNG → Upload to Storage → Save URL
                                        ↓
                                  Canvas Rendering
                                  - Background color
                                  - Frame decoration
                                  - Photos (Polaroid style)
                                  - Location maps
                                  - Date & text
                                  - Sprinkles (icons)
```

### Backend (Supabase Edge Function)

**New Function:** `render-flipbook-page`

**Inputs:**
- Entry ID

**Process:**
1. Fetch entry with photos, tags, location, Smart Page data
2. Create 800×1142 canvas
3. Render background (color_theme)
4. Draw frame decoration PNG
5. Render photos/maps at computed coordinates
6. Draw text (date, highlight_text) with Google Fonts
7. Place sprinkles (icon overlays)
8. Export as PNG
9. Upload to Supabase Storage: `flipbook-pages/{entry_id}.png`
10. Update `entries.page_image_url`

**Technology Options:**
- **Option A:** `canvas` for Deno (lightweight, fast)
- **Option B:** Puppeteer/Playwright (full browser, more features but heavier)
- **Option C:** ImageMagick via Deno FFI (image manipulation)

**Recommended:** Canvas for Deno (good balance of features and performance)

### Database Schema Changes

```sql
-- Add page_image_url column to entries table
ALTER TABLE entries
ADD COLUMN page_image_url TEXT;

-- Update view to include page_image_url
CREATE OR REPLACE VIEW public.entries_with_photos_and_tags AS
SELECT
    e.id,
    e.log_id,
    e.created_at,
    e.updated_at,
    e.event_date,
    e.highlight_text,
    e.location_lat,
    e.location_lng,
    e.location_display_name,
    e.location_is_user_overridden,
    e.page_layout_type,
    e.color_theme,
    e.sprinkles,
    e.is_processed,
    e.page_image_url,  -- NEW
    -- ... photos and tags aggregation
FROM public.entries e
-- ... rest of view
```

### Frontend Changes

**Before (Widget-based):**
```dart
SmartPageRenderer(entry: entry)
// Renders: Stack with background, frame, photos, text, sprinkles
```

**After (Image-based):**
```dart
Transform.scale(
  scale: scale,
  child: CachedNetworkImage(
    imageUrl: entry.pageImageUrl,
    width: 800,
    height: 1142,
    fit: BoxFit.contain,
    placeholder: (context, url) => ShimmerPlaceholder(),
    errorWidget: (context, url, error) => FallbackToWidgetRenderer(),
  ),
)
```

### Worker Triggers

**When to regenerate page image:**
1. Entry created (via `api-entries` POST)
2. Entry updated (via `api-entries` PATCH)
3. Photos added/removed
4. Tags changed (affects color_theme via Smart Pages Engine)
5. Location changed

**Implementation:**
- Database trigger on `entries` table UPDATE/INSERT
- Calls Edge Function `render-flipbook-page`
- Async processing (user doesn't wait)
- Fallback to widget rendering if image generation fails

### Caching Strategy

**Client-side:**
- Use `cached_network_image` package (already in dependencies)
- Cache page images locally
- Cache invalidation on entry update

**CDN:**
- Supabase Storage serves images via CDN
- Automatic edge caching
- Low latency globally

### Storage Estimates

**Per page image:**
- Resolution: 800×1142px
- Format: PNG (lossless) or WebP (better compression)
- Estimated size: 200-500KB (with compression)

**Comparison:**
- Current: ~50KB JSON + photos already stored separately
- New: +200-500KB per entry for page image
- Acceptable for read-heavy flipbook viewing

### Migration Path

**Phase 1: Dual Rendering**
1. Deploy backend page generation
2. Generate images for new entries only
3. Client checks: if `page_image_url` exists → show image, else → render widgets
4. Monitor performance and quality

**Phase 2: Backfill**
5. Background job to generate images for existing entries
6. Gradual rollout

**Phase 3: Full Migration**
7. All entries have images
8. Remove client-side widget rendering code
9. Simplify frontend

## Open Questions

1. **Font Rendering:** How to load Google Fonts in Edge Function?
   - Bundle font files in function?
   - Use system fonts as fallback?

2. **Frame Decoration:** How to overlay PNG frame in canvas?
   - Include as asset in function deployment

3. **Map Rendering:** Static map vs. screenshot of flutter_map?
   - Use static map API (Mapbox, Google, OSM)
   - Or pre-render map tiles

4. **Sprinkles (Icons):** Material Icons in server rendering?
   - Convert to SVG/PNG assets
   - Include in function deployment

5. **Regeneration Queue:** Handle burst updates?
   - Queue system for image generation
   - Rate limiting

## Success Metrics

- **Consistency:** Same entry renders identically on all devices
- **Performance:** Image load time < 1s on 3G
- **Quality:** No visible artifacts when scaling
- **Storage:** Total storage increase < 30%
- **Reliability:** 99.9% successful image generation

## Alternative Considered: Absolute Coordinates

**Approach:** Send absolute pixel coordinates from backend, render widgets on client.

**Rejected because:**
- Still requires client-side layout engine
- Doesn't solve font rendering differences
- More complex than image generation
- Doesn't achieve pixel-perfect consistency

## References

- Related planning docs: `/docs/planning/backend-photo-layout-coordinates.md`
- Current implementation: `app/lib/features/flipbook/widgets/smart_page_renderer.dart`
- CLAUDE.md architecture principles: Backend Authoritative

---

**Implementation Timeline:** Post-V1, estimate 1-2 weeks
**Dependencies:** Canvas library for Deno, Google Fonts hosting strategy
