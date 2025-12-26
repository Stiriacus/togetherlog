# V2: Interactive Scrapbook Editor

**Phase:** V2 (Major Feature Release)
**Created:** 2025-12-26
**Status:** Planned
**Priority:** High (Core Vision)
**Effort:** Major release
**Prerequisites:** V1.5 complete (database schema ready)

---

## Vision

Transform TogetherLog from an **automated flipbook generator** into a **full interactive scrapbook creation tool**, giving users complete creative control while preserving the magic of Smart Pages as a starting point.

**Core Philosophy:**
> Smart Pages create the foundation. Users add the soul.

---

## User Experience Flow

### Current (V1): Automated Only

```
1. User creates entry (photos, text, tags, location)
2. Backend generates Smart Page (layout, colors, sprinkles)
3. User views flipbook (read-only)
4. [Optional] Regenerate layout (new random variation)
```

### V2: Automated + Interactive

```
1. User creates entry (photos, text, tags, location)
2. Backend generates Smart Page (beautiful baseline)
3. User views flipbook
4. **[NEW] User enters Edit Mode**
   ↓
5. Interactive canvas appears
6. User customizes:
   - Drag photos/maps to new positions
   - Resize and rotate freely
   - Adjust layering (bring forward, send back)
   - Add decorations (leaves, stickers, tape)
   - Add custom text boxes
   - Change background color
7. **[NEW] Save edits**
8. Flipbook renders custom layout
9. **[NEW] Export/share customized page**
```

---

## Feature Breakdown

## Feature 1: Edit Mode Entry & Canvas

**Priority:** Critical (Foundation)
**Effort:** Large

### 1.1 Edit Button

**Location:** Flipbook page (overlay, top-right corner near regenerate button)

**UI:**
- Icon: `Icons.edit` or `Icons.create`
- Text: "Edit Page"
- Position: Top-right, next to existing "Regenerate" button
- Behavior: Navigates to editor screen

**Implementation:** Add edit button overlay positioned next to regenerate button

### 1.2 Editor Screen

**New Route:** `/logs/:logId/entries/:entryId/edit`

**Components:**
- Header with Save/Reset buttons
- Canvas (fixed 800×1142) with interactive rendering
- Tools Panel for decorations, text, colors
- Layers Panel for z-index management

### 1.3 Canvas Implementation

**Requirements:**
- Fixed canvas size: 800×1142px (DIN A5)
- Scrollable/zoomable on small screens
- Gesture detection for drag/resize/rotate
- Selection state management
- Optional grid overlay

**State Management:**
- EditorState tracking items, decorations, selection
- Methods for move, resize, rotate, delete operations
- Save and reset functionality

---

## Feature 2: Drag & Drop System

**Priority:** Critical
**Effort:** Large

### 2.1 Draggable Items

**Requirements:**
- Wrap items with gesture detection
- Tap to select, drag to move
- Show selection handles when selected
- Support rotation transforms

### 2.2 Selection Handles

**UI Elements:**
- Corner handles for resize
- Rotation handle above item
- Delete button
- Layer controls (forward/back)

**Functionality:**
- Drag corner handles to resize
- Drag rotation handle to rotate
- Click delete to remove item
- Layer buttons adjust z-index

### 2.3 Constraints & Boundaries

**Requirements:**
- Constrain items within content box (726×1144px)
- Min/max item sizes (80-600px)
- Optional snap-to-grid (8px)

---

## Feature 3: Decoration Library & Picker

**Priority:** High
**Effort:** Large

### 3.1 Decoration Picker UI

**Location:** Bottom toolbar in editor

**Features:**
- Tabbed categories (stickers, tape, frames, textures)
- Searchable by tags
- Thumbnail grid
- Click to add to canvas

### 3.2 Decoration Data

**Data Providers:**
- Fetch decorations from database
- Filter by category
- Load asset URLs from Supabase Storage

**Add to Canvas Flow:**
1. User selects decoration
2. Appears at canvas center
3. Auto-selected with handles
4. User drags to position

---

## Feature 4: Layering System (Z-Index)

**Priority:** Medium
**Effort:** Medium

### 4.1 Layers Panel

**Location:** Bottom-right of editor

**Features:**
- List items in z-order (top = front)
- Drag to reorder layers
- Toggle visibility
- Click to select
- Up/down buttons

### 4.2 Z-Index Management

**Operations:**
- Update z-index values
- Bring forward / send backward
- Reorder items in state

**Rendering:**
- Sort items by z-index
- Render in order (low to high)
- Text block on top by default

---

## Feature 5: Save & Persistence

**Priority:** Critical
**Effort:** Medium

### 5.1 Save Button

**Location:** Top-right header in editor

**Behavior:**
- Enabled only when `isDirty = true`
- Shows loading spinner during save
- Success: Toast notification + navigate back to flipbook
- Error: Show error message, stay in editor

### 5.2 Save Implementation

**Client Side:**
- Build custom_layout JSONB from editor state
- Send to backend API
- Clear isDirty flag
- Invalidate cache for re-render

**Backend API:**
- New endpoint: `PATCH /api-entries/:entry_id/custom-layout`
- Validate JSONB structure
- Update entries table
- Set is_customized flag

---

## Feature 6: Advanced Editing Tools

**Priority:** Medium
**Effort:** Large

### 6.1 Text Boxes

**Feature:** Custom text placement
- Add text button in toolbar
- Double-click to edit
- Customize font, color, alignment

### 6.2 Background Color

**Feature:** Change page background
- Color picker in toolbar
- Preset themes
- Custom color option

### 6.3 Copy & Duplicate

**Feature:** Duplicate items
- Duplicate button when selected
- Keyboard shortcut support

### 6.4 Undo/Redo

**Feature:** Edit history
- History stack implementation
- Undo/redo operations
- Keyboard shortcuts

---

## Feature 7: Smart Page Reset

**Priority:** Medium
**Effort:** Small

### Purpose

Allow users to revert customizations and return to Smart Page baseline.

### Implementation

**Reset Button:** Top header with confirmation dialog

**Functionality:**
- Revert to Smart Page baseline
- Clear custom_layout JSONB
- Reset is_customized flag
- Requires save to persist

---

## Technical Architecture

### Data Flow

```
Editor UI
   ↓
EditorStateNotifier (Riverpod)
   ↓
CustomLayout Model
   ↓
EntriesRepository
   ↓
Supabase API
   ↓
Database (custom_layout JSONB)
   ↓
Flipbook Viewer (renders custom layout)
```

### File Structure

**New Feature Module:** `page_editor/`
- Main editor screen
- State providers (editor, decorations)
- Widgets (canvas, handles, picker, panels)
- Data models and repositories
- Utilities for coordinates and collision

---

## Testing Strategy

### Manual Testing Checklist

#### Core Editing
- [ ] Enter edit mode from flipbook
- [ ] Drag photos to new positions
- [ ] Resize photos (all 8 handles)
- [ ] Rotate photos (rotation handle)
- [ ] Delete photos (delete button)
- [ ] Drag maps (same as photos)
- [ ] Drag decorations

#### Decorations
- [ ] Browse decoration library
- [ ] Filter by category
- [ ] Add sticker to canvas
- [ ] Add tape decoration
- [ ] Resize decoration
- [ ] Rotate decoration
- [ ] Delete decoration
- [ ] Duplicate decoration

#### Layering
- [ ] Reorder layers via drag
- [ ] Bring item forward
- [ ] Send item backward
- [ ] Toggle visibility
- [ ] Select item from layers panel

#### Save & Reset
- [ ] Save custom layout
- [ ] Exit editor and verify changes in flipbook
- [ ] Re-enter editor, verify state persisted
- [ ] Reset to Smart Page
- [ ] Save reset

#### Advanced Features
- [ ] Add custom text box
- [ ] Edit text content
- [ ] Change background color
- [ ] Undo edit
- [ ] Redo edit
- [ ] Duplicate item (Cmd+D)

#### Edge Cases
- [ ] Items cannot leave content box
- [ ] Minimum item size enforced
- [ ] Maximum item size enforced
- [ ] Works with 0 photos (decorations only)
- [ ] Works with 4 photos + decorations
- [ ] Performance with 20+ decorations

---

## Success Metrics

### User Engagement
- ✅ 50%+ of users customize at least 1 page
- ✅ Average 3-5 decorations added per customized page
- ✅ 30%+ of users customize multiple pages

### Technical
- ✅ Editor loads < 1s
- ✅ Drag interactions 60 FPS
- ✅ Save operation < 2s
- ✅ No data loss on save
- ✅ Custom layouts render identically in flipbook

### Qualitative
- ✅ User feedback: "easy to use"
- ✅ User feedback: "feels creative and fun"
- ✅ Users share customized pages on social media

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Complex UI overwhelming | High | Progressive disclosure, tooltips, onboarding |
| Performance issues with many items | Medium | Optimize rendering, limit max items |
| Custom layouts break on export | High | Test export thoroughly, fallback to Smart Page |
| Decoration assets not loading | Medium | Cache aggressively, fallback to placeholders |
| Users lose work (no autosave) | High | Implement autosave every 30s |

---

## Future Enhancements (V3+)

### Collaboration
- Multi-user editing (real-time)
- Share logs with edit permissions
- Activity history (who edited what)

### Templates
- Save custom layouts as templates
- Community template library
- Import/export templates

### Advanced Assets
- User-uploaded decorations
- AI-generated stickers
- Animated decorations (GIFs)

### Mobile Optimization
- Touch-optimized editor
- Simplified mobile UI
- Gesture shortcuts (pinch to zoom, two-finger rotate)

---

## Launch Plan

### Phase 1: Beta (Internal)
- Deploy to staging
- Test with 10-20 beta users
- Gather feedback
- Fix critical bugs

### Phase 2: Limited Release
- Deploy to production (feature flag)
- Enable for 10% of users
- Monitor metrics
- Iterate based on feedback

### Phase 3: Full Release
- Enable for all users
- Marketing push
- Tutorial videos
- Blog post announcement

---

## Conclusion

V2 transforms TogetherLog into a **true scrapbook tool**, empowering users to express creativity while maintaining the convenience of Smart Pages.

**This is where TogetherLog becomes magical. ✨**

---

**Next Steps:**
1. Review this plan with stakeholders
2. Complete V1 and V1.5 first (prerequisites)
3. Begin V2 implementation with Feature 1 (Edit Mode & Canvas)
4. Iterate based on user testing
5. Ship and celebrate! 🎉
