# TogetherLog - Development Milestones

This document tracks the development progress of TogetherLog and provides detailed implementation steps for each milestone.

## Development Principles

**ALWAYS follow these core principles:**

1. **Backend Authoritative**: All business logic (Smart Pages, image processing, geocoding) runs on the backend
2. **Frontend Lean**: Flutter client only renders UI and handles user input - no Smart Page logic on client
3. **Clean Architecture**: Strict separation between data/features/core layers
4. **No Feature Drift**: Only implement what's specified in the requirements
5. **Backtest Everything**: Verify against v1Spez.md and architecture.md before committing
6. **Commit After Each Milestone**: Use format `feat(milestone-X): description, backtested`

## Workflow for Every Milestone

```
READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → PUSH → NEXT
```

1. **READ**: Read all relevant docs (README.md, v1Spez.md, v2optional.md, architecture.md)
2. **ANALYZE**: Check existing folder structure and verify previous milestones
3. **PLAN**: Create detailed implementation plan with file list
4. **CODE**: Implement features following clean architecture
5. **BACKTEST**: Verify against requirements, check file sizes, test architecture compliance
6. **FIX**: Address any issues found during backtest
7. **COMMIT**: Commit with detailed message following format
8. **PUSH**: Push to branch `claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3`
9. **NEXT**: Move to next milestone

---

## ✅ Completed Milestones (0-8)

### MILESTONE 0: Project Foundation ✅
**Commit**: Initial setup
- Created monorepo structure (/app, /backend, /docs)
- Set up Flutter app scaffold
- Set up Supabase backend structure

### MILESTONE 1: Flutter App Init ✅
**Commit**: Flutter dependencies
- Added all dependencies to pubspec.yaml
- flutter_riverpod, go_router, supabase_flutter, dio, image_picker, page_flip

### MILESTONE 2: Backend Folder Structure ✅
**Commit**: Backend organization
- Created backend/edge-functions/ structure
- Created backend/supabase/ for migrations and config

### MILESTONE 3: Database Schema ✅
**Commit**: `1d5e052`, `751df9c`
- Migration 001: Core schema (users, logs, entries, photos, tags, entry_tags)
- Migration 002: Optimized views and functions (entries_with_photos_and_tags)
- Row Level Security (RLS) policies for all tables
- Storage buckets for photos and thumbnails
- 19 seed tags (Activity, Event, Emotion categories)
- **Fixed**: UUID function (`gen_random_uuid()` instead of `uuid_generate_v4()`)
- **Fixed**: Folder structure (migrations under supabase/migrations)
- **Fixed**: SQL syntax (ORDER BY inside json_agg, subquery aggregation)

### MILESTONE 4: Logs REST API ✅
**Commit**: `1d5e052`
- `backend/edge-functions/api/logs/index.ts` (267 lines)
- Complete CRUD: GET /logs, GET /logs/:id, POST /logs, PATCH /logs/:id, DELETE /logs/:id
- Shared utilities: cors.ts, auth.ts, validation.ts
- Supabase Auth integration with RLS enforcement

### MILESTONE 5: Entries REST API ✅
**Commit**: `751df9c`
- `backend/edge-functions/api/entries/index.ts` (495 lines)
- Complete CRUD for entries with photos, tags, and location
- GET /tags - List all tags
- GET /logs/:logId/entries - List entries for a log
- GET /entries/:id - Get single entry with photos and tags
- POST /logs/:logId/entries - Create entry
- PATCH /entries/:id - Update entry
- DELETE /entries/:id - Delete entry
- Photo management (associate/delete photos)
- Tag assignment
- Location handling

### MILESTONE 6: Worker Functions ✅
**Commit**: `3ca4c96`
- `backend/edge-functions/workers/reverse-geocode/index.ts` (146 lines)
  - Fully functional GPS → location name with Nominatim
  - Rate limiting (1 req/sec)
  - Smart address parsing
- `backend/edge-functions/workers/process-photo/index.ts` (105 lines)
  - Photo URL generation
  - V1 placeholder for EXIF extraction (documented limitations)
- `backend/edge-functions/workers/compute-colors/index.ts` (89 lines)
  - V1 placeholder for color extraction (documented limitations)

### MILESTONE 7: Smart Pages Engine ✅
**Commit**: `dfb6879`
- `backend/edge-functions/workers/compute-smart-page/index.ts` (241 lines)
- **RULE 1**: Layout type selection based on photo count
  - 0-1 photos → single_full
  - 2-4 photos → grid_2x2
  - 5-6 photos → grid_3x2
- **RULE 2**: Color theme selection (Emotion-Color-Engine V1)
  - Tag-based priority mapping
  - Fallback to dominant photo color
  - Default to neutral
- **RULE 3**: Sprinkles selection (decorative icons)
  - Tag-to-icon mapping
  - Max 3 sprinkles
- Backend authoritative - all logic server-side

### MILESTONE 8: Flutter Auth UI ✅
**Commit**: `93a3418`
- Data layer: supabase_client.dart, models/user.dart (57 lines)
- Auth repository: auth_repository.dart (107 lines)
- State management: auth_providers.dart (29 lines - Riverpod)
- UI widgets: login_form.dart (135 lines), signup_form.dart (175 lines)
- Auth screen: auth_screen.dart (118 lines - tab-based)
- Routing: core/routing/router.dart (59 lines - go_router with auth redirects)
- App setup: main.dart (66 lines - Supabase init, theme)
- Placeholder: logs_screen.dart (50 lines - with sign-out button)
- Documentation: Updated app/README.md
- **Total**: 741 lines of clean, documented code

---

## ⏳ Remaining Milestones (9-12)

### MILESTONE 9: Flutter Logs Feature

**Goal**: Implement logs list, create, and edit functionality in Flutter app.

**Requirements** (from v1Spez.md):
- Display list of logs for current user
- Create new log (name, type: Couple/Family/Solo)
- Edit existing log
- Delete log with confirmation
- Navigate to entries when log is selected

**Implementation Steps**:

1. **Create Logs API Client** (`app/lib/data/api/logs_api_client.dart`)
   - Methods: fetchLogs(), fetchLog(id), createLog(name, type), updateLog(id, data), deleteLog(id)
   - Use dio with Supabase Auth headers
   - Base URL from environment variable

2. **Update Log Model** (`app/lib/data/models/log.dart`)
   - Add fromJson/toJson
   - Add fields: id, user_id, name, type, created_at, updated_at

3. **Create Logs Repository** (`app/lib/features/logs/data/logs_repository.dart`)
   - Wrapper around API client
   - Error handling

4. **Create Logs Providers** (`app/lib/features/logs/providers/logs_providers.dart`)
   - logsRepositoryProvider - provides logs repository
   - logsListProvider - FutureProvider or AsyncNotifierProvider for logs list
   - createLogProvider - handles log creation
   - updateLogProvider - handles log updates
   - deleteLogProvider - handles log deletion

5. **Create Logs UI Widgets**:
   - `widgets/log_card.dart` - Display single log card
   - `widgets/log_list.dart` - Display list of logs
   - `widgets/create_log_dialog.dart` - Dialog for creating new log
   - `widgets/edit_log_dialog.dart` - Dialog for editing log

6. **Update LogsScreen** (`app/lib/features/logs/logs_screen.dart`)
   - Display logs list using logsListProvider
   - FloatingActionButton to create new log
   - Tap on log → navigate to entries list
   - Long press → edit/delete options
   - Handle loading and error states

7. **Update Router** (`app/lib/core/routing/router.dart`)
   - Add route: /logs/:logId/entries
   - Pass logId to entries screen

8. **Backtest**:
   - ✅ Verify all CRUD operations work
   - ✅ Check RLS policies enforce user ownership
   - ✅ Test navigation flow (logs → entries)
   - ✅ Verify loading/error states
   - ✅ Check against v1Spez.md requirements

9. **Commit**: `feat(milestone-9): implemented Flutter Logs feature, backtested`

---

### MILESTONE 10: Flutter Entries Feature

**Goal**: Implement entries creation, photo upload, and editing functionality.

**Requirements** (from v1Spez.md):
- Create new entry with photos
- Upload photos to Supabase Storage
- Add/edit highlight text
- Select tags from predefined set
- Edit/override location
- View entry details
- Edit existing entry
- Delete entry

**Implementation Steps**:

1. **Create Entries API Client** (`app/lib/data/api/entries_api_client.dart`)
   - Methods: fetchEntries(logId), fetchEntry(id), createEntry(logId, data), updateEntry(id, data), deleteEntry(id)
   - fetchTags() - get all tags

2. **Create Storage API Client** (`app/lib/data/api/storage_api_client.dart`)
   - uploadPhoto(File, entryId) - upload to Supabase Storage
   - getPhotoUrl(path) - get public URL
   - deletePhoto(path)

3. **Update Entry Model** (`app/lib/data/models/entry.dart`)
   - Complete fromJson/toJson
   - All fields from v1Spez.md section 3.1

4. **Create Tag Model** (`app/lib/data/models/tag.dart`)
   - id, name, category, icon (optional)

5. **Create Photo Model** (`app/lib/data/models/photo.dart`)
   - id, entry_id, url, thumbnail_url, display_order, metadata

6. **Create Entries Providers** (`app/lib/features/entries/providers/entries_providers.dart`)
   - entriesRepositoryProvider
   - entriesListProvider(logId) - fetch entries for a log
   - entryDetailProvider(entryId) - fetch single entry
   - tagsProvider - fetch all tags
   - createEntryProvider
   - updateEntryProvider

7. **Create Entries UI Screens**:
   - `entries_list_screen.dart` - List entries for a log (chronological)
   - `entry_detail_screen.dart` - View entry details (photos, text, tags, location)
   - Update `entry_create_screen.dart` - Complete implementation
   - `entry_edit_screen.dart` - Edit existing entry

8. **Create Entry Widgets**:
   - `widgets/entry_card.dart` - Entry preview card
   - `widgets/photo_picker.dart` - Multi-photo picker with image_picker
   - `widgets/tag_selector.dart` - Tag selection chips
   - `widgets/location_editor.dart` - Edit location with override option
   - `widgets/highlight_text_field.dart` - Text input for highlight

9. **Photo Upload Flow**:
   - User selects photos from device
   - Upload to Supabase Storage (photos bucket)
   - Get photo URLs
   - Create entry with photo references
   - Trigger backend workers via API call

10. **Update Router**:
    - /logs/:logId/entries - entries list
    - /logs/:logId/entries/create - create entry
    - /entries/:entryId - entry detail
    - /entries/:entryId/edit - edit entry

11. **Backtest**:
    - ✅ Test photo upload flow
    - ✅ Verify entry creation with all fields
    - ✅ Test tag selection
    - ✅ Test location editing
    - ✅ Check worker triggering
    - ✅ Verify against v1Spez.md section 3

12. **Commit**: `feat(milestone-10): implemented Flutter Entries feature with photo upload, backtested`

---

### MILESTONE 11: Flipbook Viewer

**Goal**: Implement 3D page-turn flipbook viewer for entries.

**Requirements** (from v1Spez.md section 7):
- Show all entries of a log in chronological order
- Each entry rendered as full page using Smart Page definition
- 3D-like page-turn animation (use page_flip package)
- Touch/swipe gestures (Android)
- Mouse drag/click (Web)
- Forward/backward navigation
- Smooth transitions
- Good performance on Web + Android

**Implementation Steps**:

1. **Create Smart Page Renderer** (`app/lib/features/flipbook/widgets/smart_page_renderer.dart`)
   - Takes entry with Smart Page data (page_layout_type, color_theme, photos, etc.)
   - Renders page based on layout type:
     - single_full → Hero layout with large photo
     - grid_2x2 → 2x2 grid layout
     - grid_3x2 → 3x2 grid layout (max 6 photos)
   - Applies color theme from backend
   - Displays sprinkles (decorative icons)
   - Shows highlight text, location, date

2. **Create Theme Builder** (`app/lib/core/theme/smart_page_theme.dart`)
   - Color theme mappings (warm_red, earth_green, ocean_blue, etc.)
   - Returns ColorScheme for each theme
   - Used by smart_page_renderer

3. **Create Layout Widgets** (`app/lib/features/flipbook/widgets/layouts/`)
   - `single_full_layout.dart` - Hero layout
   - `grid_2x2_layout.dart` - 2x2 grid
   - `grid_3x2_layout.dart` - 3x2 grid
   - Each layout widget takes photos, text, location, theme

4. **Create Sprinkles Widget** (`app/lib/features/flipbook/widgets/sprinkles_overlay.dart`)
   - Renders decorative icons from sprinkles array
   - Positioned strategically on page

5. **Update FlipbookViewer** (`app/lib/features/flipbook/flipbook_viewer.dart`)
   - Use page_flip package for 3D animation
   - Fetch entries for log (sorted chronologically)
   - Map each entry to SmartPageRenderer
   - Implement gesture controls:
     - Swipe left/right (Android)
     - Click/drag (Web)
   - Add navigation controls (arrows, page numbers)

6. **Create Flipbook Providers** (`app/lib/features/flipbook/providers/flipbook_providers.dart`)
   - flipbookEntriesProvider(logId) - fetch entries for flipbook
   - currentPageProvider - track current page index

7. **Update Router**:
   - /logs/:logId/flipbook - flipbook viewer

8. **Add Navigation from Logs Screen**:
   - Add "View Flipbook" button on logs list
   - Navigate to /logs/:logId/flipbook

9. **Backtest**:
   - ✅ Test all layout types render correctly
   - ✅ Verify color themes apply properly
   - ✅ Test page-turn animation smoothness
   - ✅ Test on Web (Chrome)
   - ✅ Check gestures work (swipe, click)
   - ✅ Verify entries show in chronological order
   - ✅ Check against v1Spez.md section 7

10. **Commit**: `feat(milestone-11): implemented Flipbook viewer with 3D page-turn animation, backtested`

---

### MILESTONE 12: Integration Testing & Final Validation

**Goal**: End-to-end testing, bug fixes, and final validation.

**Implementation Steps**:

1. **Create Test Users**:
   - Sign up 2-3 test users via auth UI

2. **Test Complete User Flow**:
   - [ ] Sign up → Log in → Create log → Create entry → Upload photos → Add tags → View flipbook
   - [ ] Edit entry → Update tags → Override location → Verify Smart Page updates
   - [ ] Create multiple entries → View flipbook → Test page-turn animation
   - [ ] Delete entry → Delete log → Sign out

3. **Test Backend Workers**:
   - [ ] Upload photo with EXIF GPS → Verify location is set
   - [ ] Create entry with tags → Verify Smart Page fields computed
   - [ ] Check color theme matches tags
   - [ ] Check layout type matches photo count
   - [ ] Verify sprinkles appear correctly

4. **Test RLS Policies**:
   - [ ] User A creates log → User B cannot access it
   - [ ] User A creates entry → User B cannot modify it
   - [ ] Verify storage policies (users can only access their photos)

5. **Test Edge Cases**:
   - [ ] Entry with 0 photos → single_full layout
   - [ ] Entry with 10 photos → grid_3x2 layout (only 6 shown)
   - [ ] Entry with no tags → neutral color theme
   - [ ] Photo without EXIF → no location
   - [ ] Manual location override → worker respects it

6. **Performance Testing**:
   - [ ] Flipbook with 50+ entries → smooth page turns
   - [ ] Large photo uploads → reasonable speed
   - [ ] API response times < 1 second
   - [ ] Web build size < 10 MB

7. **Cross-Platform Testing**:
   - [ ] Test on Chrome (Web)
   - [ ] Test on Android device (if available)
   - [ ] Test responsive design (mobile, tablet, desktop)

8. **Documentation Review**:
   - [ ] README.md accurate
   - [ ] SETUP.md complete
   - [ ] architecture.md matches implementation
   - [ ] v1Spez.md requirements all met
   - [ ] API documentation in backend/edge-functions/api/README.md

9. **Bug Fixes**:
   - Fix any issues found during testing
   - Ensure error handling is user-friendly
   - Add loading states where needed

10. **Final Checklist**:
    - ✅ All backend APIs functional
    - ✅ All worker functions operational
    - ✅ Smart Pages Engine working correctly
    - ✅ Flutter auth flow complete
    - ✅ Logs CRUD complete
    - ✅ Entries CRUD complete
    - ✅ Photo upload working
    - ✅ Flipbook viewer functional
    - ✅ RLS policies enforced
    - ✅ No feature drift
    - ✅ Backend authoritative architecture maintained
    - ✅ Clean architecture throughout

11. **Commit**: `feat(milestone-12): completed integration testing and final validation, all systems operational`

12. **Final Push**: Push all changes to branch

---

## Environment Variables Checklist

Before testing, ensure these are configured:

### Supabase (Backend)
- SUPABASE_URL
- SUPABASE_ANON_KEY
- SUPABASE_SERVICE_ROLE_KEY (for workers)

### Flutter App
- SUPABASE_URL (--dart-define or main.dart)
- SUPABASE_ANON_KEY (--dart-define or main.dart)

---

## Architecture Validation Checklist

For every milestone, verify:

- [ ] Backend authoritative - no Smart Page logic in Flutter
- [ ] Frontend lean - UI only renders and calls APIs
- [ ] Clean architecture - proper data/features/core separation
- [ ] Riverpod state management used correctly
- [ ] go_router for navigation
- [ ] Error handling in place
- [ ] Loading states shown to user
- [ ] User-friendly error messages
- [ ] No hardcoded credentials
- [ ] Code is documented with comments
- [ ] Follows Dart/Flutter style guide
- [ ] No feature drift - only specified features

---

## Git Branch

All development happens on:
```
claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3
```

Never push to main/master without explicit permission.

---

## References

- **v1Spez.md**: Product specification and requirements
- **architecture.md**: Technical architecture and design decisions
- **README.md**: Project overview and setup
- **v2optional.md**: Future features (out of scope for V1)

---

## Progress Tracker

- [x] MILESTONE 0: Project Foundation
- [x] MILESTONE 1: Flutter App Init
- [x] MILESTONE 2: Backend Folder Structure
- [x] MILESTONE 3: Database Schema
- [x] MILESTONE 4: Logs REST API
- [x] MILESTONE 5: Entries REST API
- [x] MILESTONE 6: Worker Functions
- [x] MILESTONE 7: Smart Pages Engine
- [x] MILESTONE 8: Flutter Auth UI
- [ ] MILESTONE 9: Flutter Logs Feature
- [ ] MILESTONE 10: Flutter Entries Feature
- [ ] MILESTONE 11: Flipbook Viewer
- [ ] MILESTONE 12: Integration Testing

**Current Status**: 8/12 milestones completed (66.7%)
