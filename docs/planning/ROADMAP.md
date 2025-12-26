# TogetherLog Product Roadmap

**Last Updated:** 2025-12-26
**Status:** Active Planning

---

## Overview

This roadmap coordinates all planned features and improvements for TogetherLog, organized into clear phases. Each phase builds on the previous one, creating a solid foundation for the ultimate vision: a **web-based interactive scrapbook editor**.

---

## Vision Statement

**V1:** Automated, beautiful flipbooks with Smart Pages (read-only)
**V1.5:** Polished UX + database prepared for custom layouts
**V2:** Interactive scrapbook editor with full creative control

---

## Phase Breakdown

### ✅ V1: MVP Completion (Launch-Ready)

**Goal:** Ship a stable, beautiful flipbook experience with automated Smart Pages.

**Status:** Nearly complete, final polish needed

**Core Features:**
- ✅ Entry creation (photos, text, tags, location)
- ✅ Smart Pages Engine (backend-authoritative layout/color/sprinkles)
- ✅ Flipbook viewer with page navigation
- ✅ 1-item layout (single photo or map)
- ✅ 2-item layout (photo + map side-by-side with staggering)
- ⏳ **Remaining tasks:**
  - Unified coordinate layout system (1-4 items)
  - Fade transition on page swipes
  - Icon placement with collision detection

**Planning Docs:**
- `v1-mvp-completion.md` - Remaining V1 tasks

**Target:** Complete before public launch

---

### 🎨 V1.5: UX Polish & Database Preparation

**Goal:** Enhance user experience and prepare database schema for V2 editing features.

**Status:** Planned

**Focus Areas:**

1. **Database Schema Updates**
   - Add `custom_layout` JSONB field to `entries` table
   - Add `layout_variant` seed field for deterministic randomness
   - Add `decoration_library` table for reusable assets
   - Prepare for storing custom edits

2. **UX Improvements**
   - Improved flipbook transitions (smooth fade + slide)
   - Loading states and skeletons
   - Better error handling
   - Responsive scaling on all screen sizes

3. **Performance Optimizations**
   - Image caching strategy
   - Lazy loading for flipbook pages
   - Optimized widget rebuilds

4. **Testing & Documentation**
   - Comprehensive manual testing guide
   - User feedback integration
   - Documentation updates

**Planning Docs:**
- `v1.5-ux-polish-and-database-prep.md` - V1.5 detailed plan

**Target:** 1-2 months post-launch

---

### 🚀 V2: Interactive Scrapbook Editor

**Goal:** Transform TogetherLog into a full interactive scrapbook creation tool.

**Status:** Planned

**Major Features:**

1. **Page Editor Mode**
   - Enter edit mode from flipbook viewer
   - Canvas-based editing interface
   - Real-time preview

2. **Drag & Drop**
   - Reposition photos and maps
   - Free rotation (not just ±5°)
   - Resize items
   - Z-index layering control

3. **Decoration Library**
   - Add stickers (leaves, stamps, icons)
   - Add decorative elements (tape, frames, borders)
   - Add text boxes (custom placement and styling)
   - Asset browser/picker

4. **Advanced Layout Controls**
   - Smart Page as starting point
   - Fully custom layouts
   - Layout templates (save & reuse)
   - Reset to Smart Page option

5. **Collaboration Features** (optional)
   - Share logs with multiple editors
   - Edit permissions
   - Activity history

**Planning Docs:**
- `v2-interactive-scrapbook-editor.md` - V2 comprehensive plan

**Target:** 3-6 months post-launch

---

## Feature Dependencies

```
V1 Foundation
├── Unified Coordinate Layout System ← Foundation for all future layout work
│   ├── V1.5: Database schema (custom_layout field)
│   └── V2: Editor uses same coordinate system
│
├── Polaroid Rendering (photos, maps)
│   └── V2: Editor reuses same polaroid widgets
│
└── Smart Pages Engine (backend)
    ├── V1.5: Continues as baseline generator
    └── V2: Creates initial layout before editing

V1.5 Preparation
├── custom_layout JSONB field ← Stores edited layouts
├── layout_variant field ← Deterministic randomness
└── decoration_library table ← Asset management

V2 Editor
├── Requires: V1 coordinate system
├── Requires: V1.5 database schema
└── Enables: Full creative control
```

---

## Architecture Evolution

### V1: Client-Side Layout Computation (Current)

```
Entry Data → [Client: Coordinate Layout System] → Render Widgets
```

**Rationale:** Rapid iteration, simple backend

### V1.5: Database Prepared for Custom Layouts

```
Entry Data → [Client: Coordinate Layout OR Custom Layout] → Render Widgets
                                  ↓
                        Store custom_layout JSONB
```

**Rationale:** Backward compatible, prepares for V2

### V2: Full Editor with Custom Layouts

```
Entry Data → Smart Page (baseline) → [Editor: User Customization] → Save → Render
                                            ↓
                                     custom_layout JSONB
                                     (positions, decorations, etc.)
```

**Rationale:** True scrapbook experience, backend stores user creativity

---

## Planning Document Index

### Active Planning (Do Next)

| Document | Phase | Priority | Status |
|----------|-------|----------|--------|
| `v1-mvp-completion.md` | V1 | **High** | Ready to implement |
| `v1.5-ux-polish-and-database-prep.md` | V1.5 | Medium | Planned |
| `v2-interactive-scrapbook-editor.md` | V2 | Low | Planned |

### Supporting Documents

| Document | Purpose | Referenced By |
|----------|---------|---------------|
| `unified-coordinate-layout-system.md` | Technical spec for V1 layout system | V1, V2 |
| `flipbook-fade-transition.md` | Small UX enhancement | V1 |
| `page-dimensions-content-box.md` | Foundation constants | V1, V2 |
| `icon-placement-system.md` | Sprinkles collision detection | V1 |

### Archived (Historical Reference)

| Document | Why Archived |
|----------|--------------|
| `layout-computation-service.md` | Superseded by `unified-coordinate-layout-system.md` |
| `backend-photo-layout-coordinates.md` | Deferred to post-V2 (backend image generation path) |
| `backend-page-image-generation.md` | Deferred to post-V2 (alternative rendering approach) |

---

## Decision Log

### Key Architectural Decisions

**Decision 1: Client-Side Layout for V1**
- **Date:** 2025-12-26
- **Decision:** Use client-side coordinate computation for V1 (not backend)
- **Rationale:** Faster iteration, simpler backend, adequate for MVP
- **Future:** May migrate to backend-authoritative in V3+ if needed

**Decision 2: Smart Page + Custom Edits (V2)**
- **Date:** 2025-12-26
- **Decision:** Smart Page generates baseline, user can customize in editor
- **Rationale:** Best of both worlds - automation + creativity
- **Alternative Rejected:** Fully manual from scratch (too much work for users)

**Decision 3: JSONB for Custom Layouts**
- **Date:** 2025-12-26
- **Decision:** Store custom layouts as JSONB in `entries.custom_layout`
- **Rationale:** Flexible schema, easy to evolve, good PostgreSQL support
- **Alternative Rejected:** Separate `layout_items` table (over-engineered for V1.5)

---

## Success Metrics

### V1 (MVP Launch)
- ✅ All core features working
- ✅ Manual testing complete
- ✅ No critical bugs
- ✅ Smooth flipbook experience
- Target: 100+ entries created in beta

### V1.5 (Polish)
- ✅ Improved load times (< 2s initial load)
- ✅ Smooth transitions (60 FPS)
- ✅ Database schema ready for V2
- Target: 500+ entries, positive user feedback

### V2 (Editor)
- ✅ Users can edit page layouts
- ✅ Decoration library with 20+ assets
- ✅ Custom layouts render correctly
- ✅ Editor is intuitive (< 5 min learning curve)
- Target: 50%+ of users customize at least 1 page

---

## Risk Assessment

### V1 Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Layout bugs on edge cases | Medium | Thorough manual testing |
| Performance on large logs | Low | Lazy loading (already planned) |
| Browser compatibility | Low | Test on Chrome/Firefox/Safari |

### V1.5 Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Database migration fails | High | Test migrations thoroughly, backup before deploy |
| Performance degradation | Medium | Monitor metrics, optimize if needed |

### V2 Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Editor complexity overwhelming users | High | Iterative UX testing, simple defaults |
| Custom layouts break on different screens | High | Fixed canvas size (800×1142), scale consistently |
| Decoration asset management | Medium | Start with small curated library, expand gradually |

---

## Effort Estimates

**V1 Completion:** Critical tasks
- Unified coordinate layout: Large effort
- Fade transition: Small effort
- Icon placement: Medium effort
- Testing: Medium effort

**V1.5 Implementation:** Substantial undertaking
- Database schema updates: Medium effort
- UX improvements: Large effort
- Testing & documentation: Medium effort

**V2 Implementation:** Major release
- Editor foundation: Large effort
- Drag & drop system: Large effort
- Decoration library: Medium effort
- Custom layout storage: Medium effort
- Polish & testing: Large effort

---

## Questions to Resolve

### V1
- [ ] Should icons appear behind or in front of photos? (See `icon-placement-system.md`)
- [ ] Final padding values for content box? (64/48 or adjust?)

### V1.5
- [ ] Which UX improvements are highest priority?
- [ ] Should we add undo/redo to V1.5 or wait for V2?

### V2
- [ ] How extensive should decoration library be at launch?
- [ ] Should users be able to upload custom decorations?
- [ ] Multi-user editing in V2 or V3?
- [ ] Should edited layouts be shareable as templates?

---

## Next Steps

1. **Review this roadmap** with stakeholders
2. **Implement V1 remaining tasks** (`v1-mvp-completion.md`)
3. **Launch V1** and gather user feedback
4. **Refine V1.5/V2 plans** based on real usage data
5. **Begin V1.5** after stable V1 deployment

---

## Related Documentation

- **Product Spec:** `docs/v1Spez.md` (V1 MVP requirements)
- **Architecture:** `docs/architecture.md` (Technical decisions)
- **Design System:** `docs/design-system.md` (UI/UX contract)
- **Testing Guide:** `docs/testing-guide.md` (Manual QA procedures)
- **Changes Log:** `docs/CHANGES.md` (Implementation history)

---

**This is a living document.** Update as priorities shift and features evolve.
