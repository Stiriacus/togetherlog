# Interactive Page Editor - Implementation Plan

**Created:** 2025-12-28
**Status:** Ready for Implementation
**Priority:** High (Core Feature)
**Architecture:** Client-side Smart Pages with Interactive Customization

---

## Overview

This document specifies the implementation of the interactive scrapbook page editor for TogetherLog. This feature transforms TogetherLog from an auto-generated scrapbook into a creative scrapbooking tool where users can customize page layouts, add decorations, and express creativity while maintaining the convenience of Smart Page auto-generation.

---

## User Flow Summary

### Creating a New Entry

1. User fills out entry form (date, photos, tags, text, location)
2. User sees 2 buttons:
   - **"Open Editor"** → Navigate to interactive editor
   - **"Scrapbook Page"** → Auto-generate Smart Page and save (skip editing)

### Opening Editor Path

1. User clicks "Open Editor"
2. Dialog appears: **"How would you like to start?"**
   - Option A: "Auto-generate Smart Page" (recommended)
   - Option B: "Start with blank canvas"
3. Editor screen opens:
   - If auto-generated: Canvas pre-populated with photos, layout, colors, sprinkles
   - If blank: Empty canvas, user builds from scratch
4. User customizes page (drag, resize, add decorations, etc.)
5. User clicks "Save" button
6. Layout saved to backend as `custom_layout` JSONB
7. Navigate to scrapbook view

### Skip Editor Path

1. User clicks "Scrapbook Page"
2. Client computes Smart Page layout automatically
3. Layout saved to backend immediately
4. Navigate to scrapbook view
5. User can click "Edit Page" from entry details or scrapbook to customize later

### Editing Existing Entry

1. User views entry in scrapbook or entry details
2. User clicks "Edit Page" button
3. Editor opens with existing layout loaded
4. User customizes
5. User clicks "Save"
6. Updated layout saved to backend

---

## Feature Breakdown

## Phase 1: Core Editor Infrastructure

**Priority:** Critical
**Effort:** Large
**Prerequisite:** None

### 1.1 Editor Screen & Routing

**New Route:** `/logs/:logId/entries/:entryId/edit`

**Files to Create:**
- `app/lib/features/page_editor/editor_screen.dart`
- `app/lib/core/routing/routes.dart` (update)

**UI Structure:**
```
┌─────────────────────────────────────────┐
│  Header: [Reset] [Page Name]  [Save]   │
├─────────────────────────────────────────┤
│  Toolbar: [Photos] [Decorations] [BG]  │
├──────────────────┬──────────────────────┤
│                  │                      │
│    Canvas        │   Layers Panel       │
│   (874×1240)     │   ┌──────────────┐   │
│                  │   │ □ Decoration │   │
│                  │   │ □ Photo 2    │   │
│                  │   │ □ Photo 1    │   │
│                  │   │ □ Background │   │
│                  │   └──────────────┘   │
│                  │                      │
└──────────────────┴──────────────────────┘
```

**Header Components:**
- Reset button (reverts to auto-generated Smart Page with confirmation)
- Page title/name (read-only)
- Save button (enabled when isDirty = true)

**Toolbar:**
- Photos section (manage entry photos on canvas)
- Decorations section (add items from Unsplash)
- Background color picker

**Canvas:**
- Fixed size: 874×1240px (DIN A5 at 150 DPI)
- Scrollable/zoomable container for mobile
- Frame decoration overlay (classic_boarder_olivebrown.png)
- Content area: 746×1144px (64px horizontal, 48px vertical padding)

**Layers Panel (Right Side):**
- Shows all canvas items in z-order (top = frontmost)
- Drag to reorder
- Visibility toggles (eye icon)
- Click to select item
- Up/Down arrow buttons for fine control

### 1.2 Editor State Management

**Files to Create:**
- `app/lib/features/page_editor/providers/editor_state_provider.dart`
- `app/lib/features/page_editor/models/editor_state.dart`
- `app/lib/features/page_editor/models/canvas_item.dart`

**EditorState Model:**
```dart
class EditorState {
  final String entryId;
  final List<CanvasItem> items;
  final String? selectedItemId;
  final Color backgroundColor;
  final bool isDirty;
  final bool isSaving;

  // Methods
  void addItem(CanvasItem item);
  void removeItem(String itemId);
  void updateItem(String itemId, CanvasItem updated);
  void reorderItems(int oldIndex, int newIndex);
  void selectItem(String? itemId);
}
```

**CanvasItem Model:**
```dart
enum CanvasItemType { photo, decoration, text }

class CanvasItem {
  final String id;
  final CanvasItemType type;
  final Offset position; // x, y in pixels
  final Size size; // width, height in pixels
  final double rotation; // degrees
  final int zIndex;
  final bool isVisible;

  // Type-specific data
  final String? photoUrl; // for type=photo
  final String? decorationUrl; // for type=decoration
  final String? text; // for type=text
  final TextStyle? textStyle; // for type=text
}
```

**State Operations:**
- Load existing layout from entry
- Generate initial Smart Page layout
- Track dirty state (unsaved changes)
- Undo/redo stack (optional for Phase 2)

### 1.3 Canvas Rendering

**Files to Create:**
- `app/lib/features/page_editor/widgets/editor_canvas.dart`
- `app/lib/features/page_editor/widgets/canvas_item_widget.dart`

**Canvas Widget:**
- Stack-based layout
- Background color layer
- Frame decoration overlay (Positioned.fill)
- Render all CanvasItems sorted by z-index
- Handle tap outside items to deselect

**Item Rendering:**
- Photos: NetworkImage or CachedNetworkImage
- Decorations: NetworkImage from Unsplash
- Text: Text widget with custom TextStyle
- Apply transforms: translate (position), rotate, scale (size)

**Constraints:**
- Items must stay within content area (746×1144px)
- Minimum item size: 80×80px
- Maximum item size: 600×600px

---

## Phase 2: Drag, Resize, Rotate

**Priority:** Critical
**Effort:** Large
**Prerequisite:** Phase 1

### 2.1 Selection System

**Files to Create:**
- `app/lib/features/page_editor/widgets/selection_handles.dart`
- `app/lib/features/page_editor/widgets/selectable_canvas_item.dart`

**Selection Behavior:**
- Tap item to select
- Tap canvas background to deselect
- Selected item shows handles overlay

**Selection Handles Overlay:**
```
┌───────────────────┐
│ [×]         [↻]   │  ← Delete, Rotate handle
│                   │
│    [PHOTO]        │
│                   │
│ [↗]           [↗] │  ← Resize corners
└───────────────────┘
     ↑         ↑
   Resize    Resize
```

**Handle Types:**
- 4 corner handles (resize + maintain aspect ratio)
- 1 rotation handle (above item, circular icon)
- 1 delete button (top-left, × icon)
- Optional: 2 layer buttons (bring forward, send back)

### 2.2 Drag Implementation

**Gesture Detection:**
- Use GestureDetector with onPanStart, onPanUpdate, onPanEnd
- Track initial item position
- Calculate delta from drag gesture
- Update item position in state
- Constrain to content area boundaries

**Implementation:**
```dart
GestureDetector(
  onPanStart: (details) => _onDragStart(item, details),
  onPanUpdate: (details) => _onDragUpdate(item, details),
  onPanEnd: (details) => _onDragEnd(item, details),
  child: // Canvas item
)
```

### 2.3 Resize Implementation

**Corner Handle Behavior:**
- Drag corner handle outward → increase size
- Drag corner handle inward → decrease size
- Maintain aspect ratio by default
- Enforce min/max size constraints

**Implementation:**
- Detect which corner is being dragged
- Calculate size delta based on drag distance
- Update item size in state
- Re-render item with new dimensions

### 2.4 Rotate Implementation

**Rotation Handle Behavior:**
- Rotation handle positioned above item center
- Drag rotation handle in circular motion
- Calculate angle from item center
- Update item rotation in state (0-360 degrees)

**Math:**
```dart
double calculateRotation(Offset center, Offset handlePosition) {
  final delta = handlePosition - center;
  return atan2(delta.dy, delta.dx) * 180 / pi;
}
```

---

## Phase 3: Decorations & Unsplash Integration

**Priority:** High
**Effort:** Medium
**Prerequisite:** Phase 2

### 3.1 Unsplash API Integration

**Package:** `http` or `dio` (already in project)

**Unsplash Setup:**
1. Create Unsplash Developer account
2. Get API access key
3. Store in environment variables (not committed to repo)

**API Endpoints:**
- Search photos: `https://api.unsplash.com/search/photos?query={query}&per_page=20`
- Download tracking: `https://api.unsplash.com/photos/{id}/download`

**Files to Create:**
- `app/lib/features/page_editor/services/unsplash_service.dart`
- `app/lib/features/page_editor/providers/decorations_provider.dart`
- `app/lib/features/page_editor/models/decoration_search_result.dart`

**UnsplashService:**
```dart
class UnsplashService {
  final String _accessKey;

  Future<List<DecorationSearchResult>> searchPhotos(String query);
  Future<void> trackDownload(String photoId);
}
```

**Decoration Categories (Suggested Searches):**
- Leaves
- Flowers
- Hearts
- Stars
- Stickers
- Tape
- Stamps
- Frames
- Nature
- Abstract

### 3.2 Decorations Picker UI

**Files to Create:**
- `app/lib/features/page_editor/widgets/decorations_picker.dart`
- `app/lib/features/page_editor/widgets/decoration_thumbnail.dart`

**UI Layout:**
```
┌─────────────────────────────────┐
│  Search: [____________] [🔍]    │
├─────────────────────────────────┤
│  Categories: [Leaves] [Flowers] │
│              [Hearts] [Stars]   │
├─────────────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐      │
│  │[1]│ │[2]│ │[3]│ │[4]│      │
│  └───┘ └───┘ └───┘ └───┘      │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐      │
│  │[5]│ │[6]│ │[7]│ │[8]│      │
│  └───┘ └───┘ └───┘ └───┘      │
└─────────────────────────────────┘
```

**Behavior:**
- Search bar triggers Unsplash API search
- Category buttons = pre-defined searches
- Thumbnail grid shows results (4 columns)
- Click thumbnail → add to canvas at center position
- Loading spinner during API call
- Error state for failed searches

**Adding Decoration to Canvas:**
1. User clicks decoration thumbnail
2. Create new CanvasItem:
   - type: decoration
   - decorationUrl: Unsplash image URL (small or regular size)
   - position: Canvas center
   - size: 150×150px (default)
   - zIndex: Highest + 1
3. Add item to EditorState
4. Auto-select new item (show handles)
5. Track download with Unsplash API (required by ToS)

### 3.3 Material Icons Fallback

**If Unsplash integration is delayed**, use Material Icons as decorations:

**Files to Create:**
- `app/lib/features/page_editor/widgets/material_icons_picker.dart`

**Icon Categories:**
- Nature: `Icons.park`, `Icons.forest`, `Icons.flower`, `Icons.grass`
- Celebration: `Icons.celebration`, `Icons.cake`, `Icons.star`, `Icons.favorite`
- Travel: `Icons.flight`, `Icons.hotel`, `Icons.directions_car`, `Icons.beach_access`
- Food: `Icons.restaurant`, `Icons.coffee`, `Icons.local_pizza`, `Icons.icecream`

**Rendering Icons on Canvas:**
- Use Icon widget with custom size/color
- Convert to image for export (future)
- Simpler implementation, no API key needed

---

## Phase 4: Layers Panel

**Priority:** High
**Effort:** Medium
**Prerequisite:** Phase 2

### 4.1 Layers Panel UI

**Files to Create:**
- `app/lib/features/page_editor/widgets/layers_panel.dart`
- `app/lib/features/page_editor/widgets/layer_item_tile.dart`

**Panel Layout:**
```
┌──────────────────────┐
│   Layers             │
├──────────────────────┤
│ 👁 [Decoration 3] ↑↓│  ← Top layer (z-index 4)
│ 👁 [Photo 2]      ↑↓│
│ 👁 [Photo 1]      ↑↓│
│ 👁 [Text Block]   ↑↓│
│ 👁 [Background]   ↑↓│  ← Bottom layer (z-index 0)
└──────────────────────┘
```

**LayerItemTile:**
- Eye icon (toggle visibility)
- Layer name (Photo 1, Decoration, etc.)
- Thumbnail preview (small)
- Up/Down arrows
- Drag handle (reorder via drag-drop)
- Highlight selected layer

**Interactions:**
- Click layer → Select item on canvas
- Drag layer → Reorder z-index
- Click eye icon → Toggle item visibility
- Up/Down arrows → Adjust z-index by ±1

### 4.2 Drag-to-Reorder

**Package:** `reorderable_list` or custom ReorderableListView

**Implementation:**
```dart
ReorderableListView.builder(
  itemCount: items.length,
  onReorder: (oldIndex, newIndex) {
    ref.read(editorStateProvider.notifier).reorderItems(oldIndex, newIndex);
  },
  itemBuilder: (context, index) => LayerItemTile(item: items[index]),
)
```

**Z-Index Update Logic:**
- List is sorted by z-index descending (top = highest z)
- Drag item from index A to index B
- Recalculate z-index values for all items
- Update state and re-render canvas

---

## Phase 5: Background Color Picker

**Priority:** Medium
**Effort:** Small
**Prerequisite:** Phase 1

### 5.1 Color Picker UI

**Files to Create:**
- `app/lib/features/page_editor/widgets/background_color_picker.dart`

**UI Options:**

**Option A: Preset Palette**
```
┌─────────────────────────────┐
│ Background Color            │
├─────────────────────────────┤
│  ⬜ ⬜ ⬜ ⬜ ⬜ ⬜ ⬜ ⬜   │  ← Preset colors
│  [Custom Color Picker...]   │
└─────────────────────────────┘
```

**Option B: Full Color Picker**
- Use `flutter_colorpicker` package
- Show color wheel or HSV picker
- Recent colors history

**Preset Colors (Smart Page themes):**
- Warm Red (#D84A4A)
- Earth Green (#6B8E23)
- Ocean Blue (#4682B4)
- Deep Purple (#6A4C93)
- Warm Earth (#C19A6B)
- Soft Rose (#E8B4B8)
- Neutral (#E0E0E0)

**Implementation:**
- Click color swatch → Update backgroundColor in EditorState
- Canvas re-renders with new background
- Frame decoration stays on top

---

## Phase 6: Save & Persistence

**Priority:** Critical
**Effort:** Medium
**Prerequisite:** Phase 1-4

### 6.1 Custom Layout JSONB Schema

**Database Field:** `entries.custom_layout` (JSONB)

**Schema Structure:**
```json
{
  "version": "1.0",
  "backgroundColor": "#E0E0E0",
  "items": [
    {
      "id": "photo-1",
      "type": "photo",
      "photoUrl": "https://...",
      "position": {"x": 100, "y": 150},
      "size": {"width": 300, "height": 400},
      "rotation": 5,
      "zIndex": 1,
      "isVisible": true
    },
    {
      "id": "decoration-1",
      "type": "decoration",
      "decorationUrl": "https://images.unsplash.com/...",
      "position": {"x": 400, "y": 200},
      "size": {"width": 150, "height": 150},
      "rotation": -10,
      "zIndex": 2,
      "isVisible": true
    }
  ]
}
```

**Version Field:** For future schema migrations

### 6.2 Save Implementation

**Files to Update:**
- `app/lib/features/entries/data/entries_repository.dart`
- `app/lib/features/entries/models/entry.dart`

**New Repository Method:**
```dart
Future<void> saveCustomLayout(String entryId, Map<String, dynamic> customLayout) {
  // PATCH /api-entries/{entryId}
  // Body: { custom_layout: {...}, is_customized: true }
}
```

**Save Button Behavior:**
1. User clicks Save
2. Validate all items (positions, sizes within bounds)
3. Serialize EditorState to JSONB
4. Show loading spinner
5. Call repository.saveCustomLayout()
6. On success:
   - Show success toast
   - Set isDirty = false
   - Navigate back to scrapbook or entry details
7. On error:
   - Show error message
   - Stay in editor
   - Keep isDirty = true

### 6.3 Unsaved Changes Warning

**Files to Create:**
- `app/lib/features/page_editor/widgets/unsaved_changes_dialog.dart`

**Behavior:**
- User tries to exit editor (back button, navigation)
- If isDirty = true, show confirmation dialog:
  - "You have unsaved changes. Discard or save?"
  - Buttons: [Discard] [Cancel] [Save]
- If isDirty = false, allow navigation

**Implementation:**
- Use WillPopScope or PopScope
- Intercept back navigation
- Show dialog conditionally

---

## Phase 7: Entry Creation Flow

**Priority:** Critical
**Effort:** Medium
**Prerequisite:** Phase 1-6

### 7.1 Entry Form Update

**Files to Update:**
- `app/lib/features/entries/widgets/entry_form.dart` (or similar)
- `app/lib/features/entries/providers/entry_form_provider.dart`

**Current Flow:**
- User fills form (date, photos, tags, text, location)
- User clicks "Create Entry" button
- Entry saved to backend
- Navigate to entries list or scrapbook

**New Flow:**
- User fills form
- User sees 2 buttons side-by-side:

```
┌──────────────────────────────────┐
│  [  Open Editor  ]               │  ← Primary CTA
│  [ Scrapbook Page ]              │  ← Secondary option
└──────────────────────────────────┘
```

**Button Actions:**

**"Open Editor" Button:**
1. Save entry to backend (without custom_layout)
2. Show dialog: "How would you like to start?"
   - Option A: "Auto-generate Smart Page" (default)
   - Option B: "Start with blank canvas"
3. Navigate to `/logs/:logId/entries/:entryId/edit`
4. Editor loads:
   - If auto-generate: Compute Smart Page, populate canvas
   - If blank: Empty canvas

**"Scrapbook Page" Button:**
1. Compute Smart Page layout client-side
2. Serialize to custom_layout JSONB
3. Save entry to backend (with custom_layout, is_customized=false)
4. Navigate to scrapbook view

### 7.2 Auto-generate Dialog

**Files to Create:**
- `app/lib/features/page_editor/widgets/editor_start_dialog.dart`

**Dialog UI:**
```
┌─────────────────────────────────────┐
│  How would you like to start?      │
├─────────────────────────────────────┤
│                                     │
│  ○ Auto-generate Smart Page         │
│    Let TogetherLog create a         │
│    beautiful layout for you         │
│                                     │
│  ○ Start with blank canvas          │
│    Build your page from scratch     │
│                                     │
│         [Cancel]  [Continue]        │
└─────────────────────────────────────┘
```

**Default Selection:** Auto-generate (recommended)

### 7.3 Smart Page Auto-Generation

**Files to Create:**
- `app/lib/features/page_editor/services/smart_page_generator.dart`

**SmartPageGenerator:**
```dart
class SmartPageGenerator {
  EditorState generateFromEntry(Entry entry) {
    // 1. Determine layout type (based on photo count)
    // 2. Select color theme (based on tags)
    // 3. Choose sprinkles (based on tags)
    // 4. Position photos on canvas (using layout rules)
    // 5. Add text block (date + highlight)
    // 6. Return populated EditorState
  }
}
```

**Layout Rules (from existing Smart Pages):**
- 0-1 photos → single_full (centered, large)
- 2-4 photos → grid_2x2 (2×2 grid)
- 5-6 photos → grid_3x2 (3×2 grid)

**Color Theme Rules (tag-based priority):**
- Romantic/In Love → warm_red
- Nature/Hiking → earth_green
- Lake/Beach → ocean_blue
- Nightlife → deep_purple
- Food/Home → warm_earth
- Travel → soft_rose
- Fallback → neutral

**Sprinkles Rules:**
- Map tags to Material Icons
- Max 3 sprinkles per page
- Positioned around photos (corners, edges)

**Implementation:**
- Extract logic from existing backend Smart Pages function
- Port to Dart (client-side)
- Generate CanvasItem objects
- Populate EditorState

---

## Phase 8: Edit Existing Entry

**Priority:** High
**Effort:** Small
**Prerequisite:** Phase 6

### 8.1 Edit Button in Scrapbook

**Files to Update:**
- `app/lib/features/scrapbook/widgets/scrapbook_page.dart` (or similar)

**Button Placement:**
- Top-right corner of scrapbook page
- Near existing "Regenerate" button (if exists)
- Icon: `Icons.edit` or `Icons.create`
- Text: "Edit Page"

**Behavior:**
1. User clicks "Edit Page"
2. Navigate to `/logs/:logId/entries/:entryId/edit`
3. Load existing custom_layout from entry
4. Populate EditorState with items
5. User customizes
6. Save updates to backend

### 8.2 Edit Button in Entry Details

**Files to Update:**
- `app/lib/features/entries/widgets/entry_detail_screen.dart` (or similar)

**Button Placement:**
- AppBar actions (top-right)
- Or in a floating action button

**Same behavior as scrapbook edit button**

### 8.3 Loading Existing Layout

**Repository Method:**
```dart
Future<Entry> getEntry(String entryId) {
  // Existing method, ensure it fetches custom_layout field
}
```

**Editor Initialization:**
1. Fetch entry from backend
2. Check if custom_layout exists
3. If yes:
   - Deserialize JSONB to EditorState
   - Populate canvas with items
4. If no:
   - Auto-generate Smart Page
   - Treat as new layout

---

## Phase 9: Reset to Smart Page

**Priority:** Medium
**Effort:** Small
**Prerequisite:** Phase 7

### 9.1 Reset Button

**Location:** Editor header (top-left)

**Button UI:**
- Icon: `Icons.refresh` or `Icons.restore`
- Text: "Reset"

**Behavior:**
1. User clicks "Reset"
2. Show confirmation dialog:
   - "Reset to Smart Page? Your customizations will be lost."
   - Buttons: [Cancel] [Reset]
3. If confirmed:
   - Re-run SmartPageGenerator.generateFromEntry()
   - Replace EditorState with new auto-generated layout
   - Set isDirty = true (requires save)
4. Canvas re-renders with Smart Page layout

---

## Technical Implementation Details

### Database Migration

**New Fields in `entries` Table:**
```sql
ALTER TABLE entries
ADD COLUMN custom_layout JSONB DEFAULT NULL,
ADD COLUMN is_customized BOOLEAN DEFAULT FALSE;

CREATE INDEX idx_entries_custom_layout ON entries USING GIN (custom_layout);
```

**Migration File:**
- `backend/supabase/migrations/YYYYMMDDHHMMSS_add_custom_layout_fields.sql`

### Backend API Update

**Endpoint:** `PATCH /api-entries/{entryId}`

**Accept New Fields:**
```typescript
// backend/supabase/functions/api-entries/index.ts
const { custom_layout, is_customized } = await req.json();

// Update entry without validation
const { data, error } = await supabase
  .from('entries')
  .update({ custom_layout, is_customized })
  .eq('id', entryId)
  .select()
  .single();
```

**No validation of custom_layout JSONB** - trust client completely

### Flutter Dependencies

**Add to `pubspec.yaml`:**
```yaml
dependencies:
  # Existing
  flutter:
    sdk: flutter
  riverpod: ^2.4.0
  dio: ^5.4.0

  # New for editor
  # flutter_colorpicker: ^1.0.3  # Optional: full color picker

  # Unsplash integration uses existing dio
```

**No additional packages required** for drag-drop (use built-in gestures)

### Environment Variables

**Add to `.env` (not committed):**
```
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here
```

**Load in Flutter:**
```dart
// app/lib/core/config/env.dart
class Env {
  static const unsplashAccessKey = String.fromEnvironment('UNSPLASH_ACCESS_KEY');
}
```

**Build command:**
```bash
flutter run --dart-define=UNSPLASH_ACCESS_KEY=your_key_here
```

---

## Implementation Order

### Sprint 1: Core Editor (Phase 1-2)
1. Editor screen & routing ✓
2. Editor state management ✓
3. Canvas rendering ✓
4. Selection system ✓
5. Drag implementation ✓
6. Resize implementation ✓
7. Rotate implementation ✓

**Deliverable:** Can open editor, see canvas, drag/resize/rotate photos

### Sprint 2: Decorations & Layers (Phase 3-4)
1. Unsplash API integration ✓
2. Decorations picker UI ✓
3. Add decorations to canvas ✓
4. Layers panel UI ✓
5. Drag-to-reorder layers ✓
6. Visibility toggles ✓

**Deliverable:** Can add Unsplash images as decorations, manage layers

### Sprint 3: Save & Entry Flow (Phase 5-7)
1. Background color picker ✓
2. Save implementation ✓
3. Unsaved changes warning ✓
4. Database migration ✓
5. Backend API update ✓
6. Entry form update (2 buttons) ✓
7. Auto-generate dialog ✓
8. Smart Page generator (client-side) ✓

**Deliverable:** Full entry creation flow with editor integration

### Sprint 4: Edit Existing & Polish (Phase 8-9)
1. Edit button in scrapbook ✓
2. Edit button in entry details ✓
3. Load existing layout ✓
4. Reset to Smart Page ✓
5. Bug fixes & refinements ✓

**Deliverable:** Can edit existing entries, reset layouts

---

## Testing Checklist

### Manual Testing

#### Core Editor
- [ ] Open editor from entry creation
- [ ] Canvas renders at correct size (874×1240)
- [ ] Frame decoration visible
- [ ] Photos render correctly
- [ ] Selection handles appear on tap
- [ ] Drag photo to new position
- [ ] Resize photo with corner handles
- [ ] Rotate photo with rotation handle
- [ ] Delete photo with delete button
- [ ] Deselect on canvas tap

#### Decorations
- [ ] Search Unsplash decorations
- [ ] Category buttons trigger searches
- [ ] Thumbnails load correctly
- [ ] Click thumbnail adds decoration to canvas
- [ ] Decoration appears at canvas center
- [ ] Decoration auto-selected after add
- [ ] Can drag/resize/rotate decoration
- [ ] Can delete decoration

#### Layers
- [ ] Layers panel shows all items
- [ ] Items listed in z-order (top = front)
- [ ] Drag layer to reorder
- [ ] Canvas updates z-index correctly
- [ ] Click layer selects item on canvas
- [ ] Visibility toggle hides/shows item
- [ ] Up/Down arrows adjust z-index

#### Background Color
- [ ] Preset colors available
- [ ] Click color updates background
- [ ] Custom color picker works
- [ ] Background color persists on save

#### Save & Load
- [ ] Save button disabled when !isDirty
- [ ] Save button enabled when isDirty
- [ ] Click Save shows loading spinner
- [ ] Success toast appears
- [ ] Navigate back to scrapbook after save
- [ ] Error message on save failure
- [ ] Unsaved changes warning on exit
- [ ] Load existing layout from entry
- [ ] Reset button re-generates Smart Page

#### Entry Flow
- [ ] Entry form shows 2 buttons
- [ ] "Open Editor" button works
- [ ] Auto-generate dialog appears
- [ ] Auto-generate creates Smart Page
- [ ] Blank canvas option works
- [ ] "Scrapbook Page" auto-saves
- [ ] Edit button in scrapbook works
- [ ] Edit button in entry details works

### Edge Cases
- [ ] Empty entry (0 photos) handled
- [ ] Max photos (6) handled
- [ ] Items stay within content area
- [ ] Min/max size constraints enforced
- [ ] Rotation wraps 0-360 degrees
- [ ] Duplicate item IDs prevented
- [ ] Invalid custom_layout JSONB handled
- [ ] Network errors handled gracefully
- [ ] Unsplash API rate limit handled

---

## Success Metrics

### User Engagement
- ✅ 70%+ of users create at least 1 entry via editor
- ✅ 50%+ of entries have customizations (is_customized=true)
- ✅ Average 2-3 decorations added per customized page

### Technical
- ✅ Editor loads in < 1s
- ✅ Drag/resize/rotate at 60 FPS
- ✅ Save operation < 2s
- ✅ No data loss on save
- ✅ Layouts render identically in scrapbook

### Qualitative
- ✅ User feedback: "easy to use"
- ✅ User feedback: "fun and creative"
- ✅ Users share customized pages

---

## Future Enhancements (Post-MVP)

### Advanced Features
- Undo/redo (history stack)
- Copy/duplicate items (Cmd+D)
- Keyboard shortcuts (Delete, Arrow keys)
- Multi-select (drag box, Shift+click)
- Alignment guides (snap to grid)
- Text boxes (custom text placement)
- Filters/effects on photos
- Stickers/stamps library
- Templates (save custom layouts as templates)

### Mobile Optimization
- Touch-optimized handles (larger tap targets)
- Pinch-to-zoom canvas
- Two-finger rotation gesture
- Simplified mobile UI

### Collaboration
- Multi-user editing (real-time)
- Activity history (who edited what)
- Comments on pages

### Export
- Download page as PNG/JPG
- Print-ready PDF export
- Share to social media

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Unsplash API rate limits | Medium | Cache popular searches, show Material Icons fallback |
| Complex drag-drop UX on mobile | High | Test extensively on mobile, simplify handles for touch |
| Performance with many items (20+) | Medium | Limit max items per page, optimize rendering |
| Users lose work (no autosave) | High | Implement unsaved changes warning, consider localStorage backup |
| Custom layouts break on export | High | Validate layout before save, test export thoroughly |

---

## Conclusion

This implementation plan transforms TogetherLog into a full-featured scrapbooking tool while maintaining the convenience of Smart Page auto-generation. The phased approach allows for incremental development and testing, with each sprint delivering tangible user value.

**Estimated Total Effort:** 4-6 weeks (solo developer, part-time)

**Next Steps:**
1. Review and approve this plan
2. Set up Unsplash API account
3. Create database migration
4. Begin Sprint 1 (Core Editor)
5. Iterate based on testing and feedback

---

## Implementation Progress

**Last Updated:** 2025-12-28

### ✅ COMPLETED: Sprint 1 - Core Editor Infrastructure (Phase 1-2)

**Status:** 100% Complete

**What Was Built:**

#### Models & State Management
- ✅ `CanvasItem` model (photos, decorations, text)
- ✅ `EditorState` model (complete editor state with JSONB serialization)
- ✅ `EditorStateNotifier` with Riverpod (all CRUD operations for canvas items)

#### UI Components
- ✅ `EditorScreen` - Main editor with app theme (antique white, warm colors)
- ✅ `EditorCanvas` - Renders 874×1240px canvas with frame decoration
- ✅ `CanvasItemWidget` - Renders items with drag support
- ✅ `SelectionHandles` - Resize/rotate/delete handles
- ✅ `LayersPanel` - Z-order management with drag-to-reorder
- ✅ `EditorToolbar` - Placeholder toolbar (Photos/Decorations/Background buttons)

#### Features Implemented
- ✅ **Drag** - Pan gesture to move items around canvas
- ✅ **Resize** - 4 corner handles with aspect ratio maintenance (80-600px constraints)
- ✅ **Rotate** - Green rotation handle with angle calculation
- ✅ **Delete** - Red × button to remove items
- ✅ **Layers** - Z-index management, bring forward/send backward
- ✅ **Selection** - Tap to select, tap canvas to deselect
- ✅ **Visibility Toggle** - Eye icon in layers panel
- ✅ **Reorder** - Drag-to-reorder in layers panel
- ✅ **Unsaved Changes Warning** - Dialog before discarding edits

#### Entry Points (All 4 Complete)
- ✅ **Entry Creation Screen** - 2 buttons: "Open Editor" / "Scrapbook Page"
  - Dialog: "Auto-generate Smart Page" or "Start with blank canvas"
- ✅ **Entry Details Screen** - Palette icon (🎨) in AppBar
- ✅ **Entry Edit Screen** - Palette icon (🎨) in AppBar
- ✅ **Scrapbook Viewer** - Floating palette button on each page

#### Routing
- ✅ Route added: `/logs/:logId/entries/:entryId/page-editor`
- ✅ Navigation configured with proper parameters

#### Theming
- ✅ App theme applied (antique white background, soft apricot panels)
- ✅ Consistent with overall TogetherLog design system
- ✅ AuthenticatedShell integration

#### Test Data
- ✅ `test_data_initializer.dart` - Sample data (4 photos, 1 decoration, 1 text)
- ✅ Auto-initialization working correctly

**Files Created:**
```
app/lib/features/page_editor/
├── editor_screen.dart
├── models/
│   ├── canvas_item.dart
│   └── editor_state.dart
├── providers/
│   └── editor_state_provider.dart
├── widgets/
│   ├── editor_canvas.dart
│   ├── canvas_item_widget.dart
│   ├── selection_handles.dart
│   ├── editor_toolbar.dart
│   └── layers_panel.dart
└── services/
    └── test_data_initializer.dart
```

**Files Modified:**
```
app/lib/core/routing/router.dart (added page-editor route)
app/lib/features/entries/entry_create_screen.dart (2 buttons + dialog)
app/lib/features/entries/entry_detail_screen.dart (Edit Page button)
app/lib/features/entries/entry_edit_screen.dart (Edit Page button)
app/lib/features/scrapbook/scrapbook_viewer.dart (floating Edit Page button)
```

**Current Capabilities:**
- Can open editor from 4 different entry points
- UI shows selection handles, resize/rotate controls
- Can manage layers (reorder, visibility, z-index) in layers panel
- Can see unsaved changes warning
- Theme matches app design system
- Test data loads correctly

**✅ FIXED - All Editor Interactions Working:**
- ✅ Drag/move - click and drag items to move
- ✅ Resize - drag blue corner handles
- ✅ Rotation - drag green top handle
- ✅ Text editing - double-click or orange edit button
- ✅ Delete - red X button
- ✅ Layer controls - up/down arrows on selection
- **Fix applied:** Removed gesture capture from canvas wrapper, added IgnorePointer to decorative elements

---

### 🚧 TODO: Sprint 2 - Decorations & Unsplash (Phase 3-4)

**Status:** Not Started

**Remaining Work:**
- [ ] Unsplash API integration
- [ ] Decorations picker UI
- [ ] Search functionality
- [ ] Add decorations to canvas

---

### 🚧 TODO: Sprint 3 - Save & Flow (Phase 5-7)

**Status:** Not Started

**Remaining Work:**
- [ ] Background color picker
- [ ] Save to backend (custom_layout JSONB)
- [ ] Database migration (custom_layout, is_customized fields)
- [ ] Backend API update (PATCH endpoint)
- [ ] Smart Page generator (client-side)

---

### 🚧 TODO: Sprint 4 - Edit & Polish (Phase 8-9)

**Status:** Not Started

**Remaining Work:**
- [ ] Load existing layout from backend
- [ ] Reset to Smart Page functionality
- [ ] Bug fixes & refinements

---

**Ready to build?** 🎨✨
