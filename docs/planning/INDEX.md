# Planning Documents Index

**Last Updated:** 2025-12-26

This index provides a quick overview of all active planning documents and their relationships.

---

## 📋 Master Coordination

### [ROADMAP.md](ROADMAP.md) ⭐ **START HERE**

**The master plan** coordinating all features across V1, V1.5, and V2.

- Overview of product vision
- Phase breakdown with timelines
- Feature dependencies
- Decision log
- Success metrics

**Read this first to understand the big picture.**

---

## 🚀 V1: MVP Completion (In Progress)

### [v1-mvp-completion.md](v1-mvp-completion.md) ✅ **IMPLEMENT NEXT**

**Priority:** Critical (Blocks Launch)
**Status:** Ready to implement

Remaining tasks to complete V1:
1. Unified coordinate layout system (1-4 items)
2. Flipbook fade transition
3. Icon placement with collision detection

**This is what needs to be done before launch.**

### Supporting V1 Documents

**Note:** These are **detailed technical specifications** for implementation. Read [v1-mvp-completion.md](v1-mvp-completion.md) first for the action plan, then reference these for implementation details.

| Document | Purpose | Type |
|----------|---------|------|
| [unified-coordinate-layout-system.md](unified-coordinate-layout-system.md) | Technical spec for coordinate-based layouts | Implementation Reference |
| [flipbook-fade-transition.md](flipbook-fade-transition.md) | Add fade effect to page swipes | Implementation Reference |
| [icon-placement-system.md](icon-placement-system.md) | Sprinkles collision detection | Implementation Reference |

---

## 🎨 V1.5: UX Polish & Database Preparation (Planned)

### [v1.5-ux-polish-and-database-prep.md](v1.5-ux-polish-and-database-prep.md)

**Priority:** High (Prepares for V2)
**Estimated Effort:** 1-2 weeks
**Prerequisites:** V1 launched and stable

Key deliverables:
1. Database schema updates (`custom_layout`, `layout_variant`, `decoration_library`)
2. UX improvements (loading states, error handling, caching)
3. Performance optimizations
4. Testing & documentation

**Implement after V1 launch and user feedback.**

---

## ✨ V2: Interactive Scrapbook Editor (Planned)

### [v2-interactive-scrapbook-editor.md](v2-interactive-scrapbook-editor.md)

**Priority:** High (Core Vision)
**Estimated Effort:** 4-6 weeks
**Prerequisites:** V1.5 complete (database schema ready)

Major features:
1. Page editor mode with canvas
2. Drag & drop system
3. Decoration library & picker
4. Layering system (z-index)
5. Save & persistence
6. Advanced editing tools (text boxes, color picker, undo/redo)
7. Smart Page reset option

**This is the ultimate vision: transforming TogetherLog into a full interactive scrapbook tool.**

---

## 📦 Archived Documents

These documents have been moved to `docs/archive/` because they are either:
- Superseded by newer planning docs
- Deferred to post-V2 timeline
- Implemented and no longer needed

| Document | Why Archived | Reference |
|----------|--------------|-----------|
| `layout-computation-service.md` | Superseded by `unified-coordinate-layout-system.md` | V1 |
| `backend-photo-layout-coordinates.md` | Deferred to post-V2 (backend-authoritative approach) | V3+ |
| `backend-page-image-generation.md` | Deferred to post-V2 (server-side rendering approach) | V3+ |
| `page-dimensions-content-box.md` | Debug tool completed - optimal padding determined | V1 |

**Archived docs are still available for reference but are not active in current planning.**

---

## 🔄 Document Dependencies

```
ROADMAP.md (Master)
    │
    ├─── V1: MVP Completion
    │    ├── v1-mvp-completion.md ← IMPLEMENT THIS
    │    │   ├── unified-coordinate-layout-system.md (detailed spec)
    │    │   ├── flipbook-fade-transition.md (detailed spec)
    │    │   └── icon-placement-system.md (detailed spec)
    │
    ├─── V1.5: UX Polish & Database Prep
    │    └── v1.5-ux-polish-and-database-prep.md
    │        └── Prepares database for V2
    │
    └─── V2: Interactive Scrapbook Editor
         └── v2-interactive-scrapbook-editor.md
             └── Depends on V1.5 database schema
```

---

## 🎯 Implementation Priority

**Right Now (This Week):**
1. Read `ROADMAP.md` to understand the big picture
2. Implement `v1-mvp-completion.md` tasks
3. Use `unified-coordinate-layout-system.md` as technical reference

**After V1 Launch (1-2 Months):**
4. Implement `v1.5-ux-polish-and-database-prep.md`
5. Gather user feedback and adjust plans

**Major Feature (3-6 Months):**
6. Implement `v2-interactive-scrapbook-editor.md`
7. Transform TogetherLog into interactive scrapbook tool

---

## 📝 How to Use These Docs

### For Development

1. **Start with ROADMAP.md** - Understand the vision
2. **Check current phase** - Are we in V1, V1.5, or V2?
3. **Read the vX-*.md action plan** - What needs to be done
4. **Reference individual technical specs** - Detailed implementation guidance
5. **Implement the feature** - Use specs as reference during coding
6. **Update CHANGES.md** - Document what you built

**Example workflow for V1:**
- Read `v1-mvp-completion.md` → See "Task 1: Unified Coordinate Layout"
- Open `unified-coordinate-layout-system.md` → Get detailed architecture and code patterns
- Implement the feature using both documents
- Mark task complete in v1-mvp-completion.md checklist

### For Planning

1. **Review ROADMAP.md** - Is it still accurate?
2. **Check dependencies** - Are prerequisites met?
3. **Update estimates** - Based on actual progress
4. **Add new docs** - When planning new features
5. **Archive old docs** - When superseded or deferred

### For Decision Making

1. **Check decision log** in ROADMAP.md
2. **Review success metrics** for each phase
3. **Assess risks** in phase docs
4. **Consider alternatives** documented in specs

---

## 🔍 Quick Reference

### Find a Document by Topic

| Topic | Document |
|-------|----------|
| **Overall vision & roadmap** | `ROADMAP.md` |
| **What to implement next** | `v1-mvp-completion.md` |
| **Layout system (1-4 items)** | `unified-coordinate-layout-system.md` |
| **Page transitions** | `flipbook-fade-transition.md` |
| **Decorative icons** | `icon-placement-system.md` |
| **Database preparation** | `v1.5-ux-polish-and-database-prep.md` |
| **Interactive editor** | `v2-interactive-scrapbook-editor.md` |

### Find a Document by Status

| Status | Documents |
|--------|-----------|
| **Active - Implement Now** | `v1-mvp-completion.md` |
| **Active - Next Phase** | `v1.5-ux-polish-and-database-prep.md` |
| **Active - Future** | `v2-interactive-scrapbook-editor.md` |
| **Reference** | `unified-coordinate-layout-system.md`, `flipbook-fade-transition.md`, etc. |
| **Archived** | See `docs/archive/` |

---

## ✅ Maintenance

### When to Update This Index

- New planning doc created → Add to appropriate section
- Doc implemented → Move to archive or delete
- Phase completed → Update status
- Priorities changed → Reorder sections

### Document Lifecycle

```
1. Created → Added to INDEX.md under appropriate phase
2. In Progress → Status updated in INDEX.md
3. Completed → Moved to archive or deleted
4. Superseded → Moved to archive with note
```

---

## 📞 Questions?

If you're unsure which document to read:

1. **For big picture:** Read `ROADMAP.md`
2. **For next steps:** Read `v1-mvp-completion.md`
3. **For V2 vision:** Read `v2-interactive-scrapbook-editor.md`
4. **For specific feature:** Use Quick Reference table above

---

**This index is a living document. Keep it updated as planning evolves!**
