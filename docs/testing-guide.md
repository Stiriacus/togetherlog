# TogetherLog - Manual Testing Guide

## 1. Introduction

### 1.1 Purpose

This guide provides step-by-step manual testing procedures for TogetherLog V1 MVP. It is designed for human testers to validate the application's functionality after changes or deployments.

**Target Audience**: QA testers, developers, and contributors with no prior TogetherLog experience.

**Testing Approach**: Manual, human-driven testing. No automated end-to-end test suites are used for V1.

### 1.2 Scope

This guide covers:
- All completed features through Milestone 11 (Flipbook viewer)
- Frontend testing (Flutter Web application)
- Backend API testing (REST endpoints via curl)
- Database verification (Supabase PostgreSQL queries)
- Integration points (Auth, Storage, Edge Functions)

**Out of Scope**:
- Automated testing frameworks
- Mobile/desktop builds (Android, iOS, macOS, Windows, Linux)
- V2 optional features (see `docs/v2optional.md`)

---

## 2. Environment & Prerequisites

### 2.1 Required Software

- **Web Browser**: Brave or Chrome (for Flutter Web)
- **Supabase Account**: Access to the deployed Supabase project
- **Supabase CLI**: For database queries and Edge Function logs
- **curl or Postman**: For REST API testing
- **Text Editor**: To view/edit configuration files
- **Flutter SDK**: 3.32.5 or later (for running the app)

### 2.2 Environment Configuration

#### 2.2.1 Supabase Project Details

- **Project ID**: `ikspskghylahtexiqepl`
- **Project URL**: `https://ikspskghylahtexiqepl.supabase.co`
- **Region**: EU (GDPR compliant)

Obtain the following from the Supabase dashboard:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (for client requests)
- `SUPABASE_SERVICE_ROLE_KEY` (for backend testing only)

#### 2.2.2 Flutter App Configuration

Before running the app, configure Supabase credentials:

**Option A: Command-line (Recommended)**
```bash
cd app
CHROME_EXECUTABLE=$(which brave-browser || which brave) flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://ikspskghylahtexiqepl.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

**Option B: Update main.dart**
Edit `app/lib/main.dart` and replace placeholder values with actual credentials.

**Warning**: Never commit credentials to version control.

### 2.3 One-Time Setup

#### 2.3.1 Verify Supabase Backend

1. Check database schema is deployed:
   ```bash
   cd backend
   supabase db push
   ```

2. Verify Edge Functions are deployed:
   ```bash
   supabase functions list
   ```
   Expected output: `api-logs`, `api-entries`, `reverse-geocode`, `process-photo`, `compute-colors`, `compute-smart-page`

3. Check Storage buckets exist:
   - Navigate to Supabase Dashboard → Storage
   - Verify buckets: `photos`, `thumbnails`
   - Verify region: EU

#### 2.3.2 Create Test Accounts

Create 2-3 test user accounts for multi-user testing:
- **Test User A**: `test-user-a@example.com` / `password123`
- **Test User B**: `test-user-b@example.com` / `password123`
- **Test User C**: `test-user-c@example.com` / `password123`

These will be used to verify Row Level Security (RLS) policies.

---

## 3. Global Manual Test Checklist

This checklist should be run after any significant change to verify core functionality:

### 3.1 Pre-Deployment Smoke Test

- [ ] **Auth**: Can sign up, log in, log out
- [ ] **Logs**: Can create, view, edit, delete logs
- [ ] **Entries**: Can create, view, edit, delete entries
- [ ] **Photos**: Can upload photos (1-6 per entry)
- [ ] **Flipbook**: Can view flipbook with page-turn animation
- [ ] **Smart Pages**: Backend computes layout, color theme, sprinkles
- [ ] **Storage**: Photos are stored and accessible
- [ ] **RLS**: Users cannot access other users' data
- [ ] **API**: All REST endpoints return expected status codes
- [ ] **Workers**: Edge Functions execute without errors

### 3.2 Post-Deployment Validation

After deploying changes:
1. Clear browser cache and local storage
2. Run "Auth Flow" test scenario (Section 4.1)
3. Run "Complete User Journey" test scenario (Section 4.6)
4. Check Supabase Dashboard for errors in Edge Function logs
5. Verify database state matches expected results

---

## 4. Feature-Level Test Scenarios

### 4.1 Authentication Flow

**Feature**: Email/password authentication with Supabase Auth

**Preconditions**: None (new user)

#### Test Case 4.1.1: Sign Up with Email/Password - Tested - WORKS as expected

**Steps**:
1. Open Flutter Web app in browser: `http://localhost:PORT` (or deployed URL)
2. You should see the Auth screen with "Login" and "Sign Up" tabs
3. Click the "Sign Up" tab
4. Enter test credentials:
   - Email: `tester-001@example.com`
   - Password: `SecurePass123!`
   - Confirm Password: `SecurePass123!`
5. Click "Sign Up" button

**Expected Results**:
- Loading indicator appears briefly
- Upon success, user is redirected to `/logs` (Logs list screen)
- No error messages displayed
- User is logged in (check if "Sign Out" option is available)

**Validation**:
- Open Supabase Dashboard → Authentication → Users
- Verify new user `tester-001@example.com` exists

#### Test Case 4.1.2: Login with Email/Password - Tested - WORKS as expected

**Steps**:
1. If logged in, sign out first
2. Click the "Login" tab on Auth screen
3. Enter credentials:
   - Email: `tester-001@example.com`
   - Password: `SecurePass123!`
4. Click "Login" button

**Expected Results**:
- Loading indicator appears briefly
- Upon success, user is redirected to `/logs`
- Dashboard loads with user's logs (if any)

#### Test Case 4.1.3: Login with Invalid Credentials - Tested - WORKS as expected

**Steps**:
1. On Login tab, enter:
   - Email: `tester-001@example.com`
   - Password: `WrongPassword`
2. Click "Login"

**Expected Results**:
- Error message: "Invalid login credentials" (or similar)
- User remains on Auth screen
- No redirect occurs

#### Test Case 4.1.4: Sign Out - Tested - WORKS as expected

**Steps**:
1. While logged in, locate the "Sign Out" button (typically in app bar or user menu)
2. Click "Sign Out"

**Expected Results**:
- User is logged out
- User is redirected to `/auth` (login screen)
- Session is cleared (refresh page should still show login screen)

#### Test Case 4.1.5: Session Persistence - Tested - WORKS as expected

**Steps**:
1. Log in as `tester-001@example.com`
2. Navigate to `/logs` (if not already there)
3. Refresh the browser page (F5 or Ctrl+R)

**Expected Results**:
- User remains logged in
- Logs page loads without redirect to `/auth`
- Session persists across page reloads

---

### 4.2 Logs Feature (Memory Books)

**Feature**: CRUD operations for logs

**Preconditions**: User is logged in

#### Test Case 4.2.1: Create New Log

**Steps**:
1. Navigate to `/logs` (Logs list screen)
2. Click "Create Log" button (usually a FAB or prominent button)
3. In the dialog:
   - Log Name: `Our Summer Adventure`
   - Log Type: `Couple` (select from dropdown)
4. Click "Create" or "Save"

**Expected Results**:
- Loading indicator appears briefly
- Dialog closes
- New log appears in the list with name "Our Summer Adventure" and type "Couple"
- Success message (snackbar/toast): "Log created successfully"

**Validation**:
- Count the number of logs in the list
- Verify "Our Summer Adventure" is present

#### Test Case 4.2.2: View Log List

**Steps**:
1. Ensure at least 2-3 logs exist (create them if needed)
2. Observe the logs list screen

**Expected Results**:
- All user's logs are displayed as cards
- Each card shows:
  - Log name
  - Log type (e.g., "Couple", "Friends")
  - Created date or last updated date
  - Action buttons (Edit, Delete, View Entries)
- Logs are sorted (e.g., by creation date, newest first)

#### Test Case 4.2.3: Edit Existing Log

**Steps**:
1. Locate the log "Our Summer Adventure" in the list
2. Click the "Edit" button (pencil icon or menu option)
3. In the edit dialog:
   - Change Log Name to: `Our Summer Road Trip`
   - Keep Log Type as `Couple`
4. Click "Save"

**Expected Results**:
- Dialog closes
- Log name updates in the list to "Our Summer Road Trip"
- Success message: "Log updated successfully"
- No duplicate logs created

**Validation**:
- Verify only one log with the new name exists
- Old name "Our Summer Adventure" should not appear

#### Test Case 4.2.4: Delete Log

**Steps**:
1. Create a temporary log: "Test Delete Log"
2. Click the "Delete" button (trash icon)
3. Confirmation dialog appears with message: "Are you sure you want to delete this log? All entries and photos will be deleted."
4. Click "Delete" to confirm

**Expected Results**:
- Dialog closes
- Log is removed from the list
- Success message: "Log deleted successfully"

**Validation**:
- Verify "Test Delete Log" no longer appears
- Check Supabase Dashboard → Database → `logs` table: record should be deleted

#### Test Case 4.2.5: Navigate to Entries

**Steps**:
1. Create a log: "Navigation Test Log"
2. Click the log card or "View Entries" button

**Expected Results**:
- App navigates to `/logs/{logId}/entries` (Entries list screen)
- Screen title shows "Navigation Test Log - Entries" or similar
- Empty state message if no entries exist: "No entries yet. Create your first memory!"

---

### 4.3 Entries Feature (Memories)

**Feature**: CRUD operations for entries with photos, tags, and location

**Preconditions**: User is logged in, at least one log exists

#### Test Case 4.3.1: Create Entry with Photos

**Steps**:
1. Navigate to a log's entries list (e.g., `/logs/{logId}/entries`)
2. Click "Create Entry" button
3. Fill in the entry creation form:
   - **Event Date**: Select a date (e.g., `2024-06-15`)
   - **Photos**: Click "Add Photos" button
     - Select 3 photos from device (use test images)
     - Verify thumbnails appear in the form
   - **Highlight Text**: Enter "Beach day with friends!"
   - **Tags**: Select tags (e.g., "Beach", "Happy", "Travel")
     - Click on tag chips to select (they should highlight)
   - **Location**: Enter "Santa Monica, CA"
     - Check "Override Location" if you want to prevent GPS overwrites
4. Click "Create Entry"

**Expected Results**:
- Loading indicator shows "Uploading photos..." and "Creating entry..."
- Upon completion:
  - Entry is created and appears in the entries list
  - Success message: "Entry created successfully"
  - Entry card shows:
    - First photo thumbnail
    - Highlight text: "Beach day with friends!"
    - Event date: June 15, 2024
    - Location: "Santa Monica, CA"
    - Selected tags as chips

**Validation**:
- Check Supabase Dashboard → Storage → `photos` bucket:
  - Verify 3 new image files uploaded (path: `{user_id}/{photo_id}.{ext}`)
- Check Database → `entries` table:
  - New entry exists with `highlight_text` = "Beach day with friends!"
  - `is_processed` should initially be `false`, then change to `true` after workers run
- Check Database → `photos` table:
  - 3 photo records linked to the entry via `entry_id`

#### Test Case 4.3.2: View Entry Details

**Steps**:
1. From the entries list, click on the entry created in 4.3.1
2. Entry detail view opens

**Expected Results**:
- Full entry details displayed:
  - Event date: June 15, 2024
  - All 3 photos in a grid layout
  - Highlight text: "Beach day with friends!"
  - Location: "Santa Monica, CA"
  - Tags: "Beach", "Happy", "Travel" (as chips)
  - Smart Page information (if processed):
    - Layout Type: `grid_2x2` or `grid_3x2`
    - Color Theme: `ocean_blue` (because "Beach" tag was selected)
    - Sprinkles: May include beach icon
  - Buttons: "Edit", "Delete", "View in Flipbook"

#### Test Case 4.3.3: Edit Entry (Text, Tags, Location)

**Steps**:
1. From entry detail view (4.3.2), click "Edit" button
2. Modify the following:
   - **Highlight Text**: Change to "Best beach day ever!"
   - **Tags**: Unselect "Travel", add "Relaxed"
   - **Location**: Change to "Santa Monica Pier, CA"
   - **Override Location**: Ensure checkbox is checked
3. Click "Save"

**Expected Results**:
- Entry updates successfully
- Detail view reflects changes:
  - Highlight text: "Best beach day ever!"
  - Tags: "Beach", "Happy", "Relaxed"
  - Location: "Santa Monica Pier, CA"
- Success message: "Entry updated successfully"

**Note**: In V1, photos cannot be edited after entry creation. Verify that photo section is locked or disabled in edit mode.

**Validation**:
- Check Database → `entries` table:
  - `highlight_text` = "Best beach day ever!"
  - `location_display_name` = "Santa Monica Pier, CA"
  - `location_is_user_overridden` = `true`
- Smart Page may recompute if tags changed (color theme might change from `ocean_blue` to something else if "Beach" tag was removed, but in this case it wasn't)

#### Test Case 4.3.4: Create Entry with No Photos

**Steps**:
1. Click "Create Entry"
2. Fill in:
   - Event Date: Select a date
   - Photos: Leave empty (do not add any photos)
   - Highlight Text: "Dinner at home"
   - Tags: "Food & Restaurant", "Home & Everyday Life"
   - Location: Leave empty
3. Click "Create Entry"

**Expected Results**:
- Entry created successfully
- Smart Page fields:
  - Layout Type: `single_full` (0-1 photos → hero layout)
  - Color Theme: `warm_earth` (Food tag priority)
  - Sprinkles: May include food utensils icon
- Entry card shows placeholder image or no image section
- Highlight text and tags displayed correctly

#### Test Case 4.3.5: Create Entry with Maximum Photos (6)

**Steps**:
1. Click "Create Entry"
2. Add 6 photos
3. Fill in other fields (date, text, tags)
4. Click "Create Entry"

**Expected Results**:
- All 6 photos upload successfully
- Smart Page Layout Type: `grid_3x2` (5-6 photos → 3x2 grid)
- Entry detail view shows all 6 photos in grid layout

**Test Edge Case**: Try to add a 7th photo
- Expected: App prevents adding more than 6 photos, shows message "Maximum 6 photos per entry"

#### Test Case 4.3.6: Delete Entry

**Steps**:
1. Create a temporary entry: "Test Delete Entry"
2. From entry detail view or entries list, click "Delete" button
3. Confirmation dialog: "Are you sure you want to delete this entry? Photos will be permanently deleted."
4. Click "Delete" to confirm

**Expected Results**:
- Entry is removed from the list
- Success message: "Entry deleted successfully"
- Associated photos are deleted from Supabase Storage

**Validation**:
- Check Database → `entries` table: record deleted
- Check Storage → `photos` bucket: files deleted
- Check Database → `photos` table: photo records deleted

---

### 4.4 Photo Upload & Storage

**Feature**: Upload photos to Supabase Storage, generate thumbnails

**Preconditions**: User is logged in, creating or editing an entry

#### Test Case 4.4.1: Upload Single Photo

**Steps**:
1. During entry creation, click "Add Photos"
2. Select 1 photo from device (e.g., a JPEG landscape photo with EXIF data)
3. Observe upload progress

**Expected Results**:
- Photo uploads to Supabase Storage
- Thumbnail preview appears in the form
- Photo is stored at path: `photos/{user_id}/{photo_id}.jpeg`
- Photo URL is accessible

**Validation**:
- Check Supabase Dashboard → Storage → `photos` bucket:
  - File exists at correct path
  - File size matches original
- Check Database → `photos` table:
  - Record created with `storage_path`, `url`, `mime_type`

#### Test Case 4.4.2: Upload Photo with EXIF GPS Data

**Steps**:
1. Use a test photo with EXIF GPS coordinates (e.g., photo taken with smartphone)
2. Upload photo during entry creation
3. Leave location field empty initially
4. Create entry

**Expected Results**:
- Photo uploads successfully
- Backend worker `reverse-geocode` is triggered
- After a few seconds (poll or refresh entry):
  - Entry's `location_display_name` is populated with reverse-geocoded location (e.g., "Berlin, Germany")
  - Entry's `location_lat` and `location_lng` are set from EXIF

**Validation**:
- Check Database → `entries` table:
  - `location_lat` and `location_lng` populated
  - `location_display_name` is human-readable
  - `location_is_user_overridden` = `false`
- Check Edge Function logs:
  ```bash
  supabase functions logs reverse-geocode
  ```
  - Look for successful API call to Nominatim

#### Test Case 4.4.3: Upload Large Photo

**Steps**:
1. Upload a high-resolution photo (e.g., 8 MB, 4000x3000 pixels)
2. Observe upload time

**Expected Results**:
- Upload completes within reasonable time (< 10 seconds on average connection)
- No errors occur
- Photo is accessible after upload

**Note**: If upload fails or is too slow, consider checking:
- Network connection
- Supabase Storage quotas
- File size limits (Supabase free tier: 1 GB storage)

#### Test Case 4.4.4: Upload Non-Image File (Negative Test)

**Steps**:
1. During entry creation, attempt to upload a non-image file (e.g., PDF, TXT)
2. Observe behavior

**Expected Results**:
- App rejects the file or shows error: "Only image files are allowed"
- No upload occurs
- User can try again with valid image

---

### 4.5 Tags & Categorization

**Feature**: Select predefined tags for entries, tag-based Smart Page theming

**Preconditions**: User is creating or editing an entry

#### Test Case 4.5.1: View All Available Tags

**Steps**:
1. Navigate to entry creation form
2. Open tag selector (e.g., click "Add Tags" or expand tags section)

**Expected Results**:
- 19 predefined tags are displayed, grouped by category:
  - **Activity** (9 tags): Nature & Hiking, Lake / Beach, City & Sightseeing, Food & Restaurant, Home & Everyday Life, Adventure / Sports, Nightlife, Roadtrip, Romantic Moments
  - **Event** (5 tags): Anniversary, Birthday, Holiday / Celebration, Travel, Surprise / Gift
  - **Emotion** (5 tags): Happy, Relaxed, Proud, In Love, Silly / Fun
- Tags are displayed as chips or checkboxes
- Categories are labeled

#### Test Case 4.5.2: Select Multiple Tags

**Steps**:
1. In tag selector, click on the following tags:
   - "Nature & Hiking"
   - "Happy"
   - "Travel"
2. Observe selected state (e.g., chips highlighted, checkboxes checked)
3. Create entry with these tags

**Expected Results**:
- All 3 tags are selected and displayed
- Entry is created with selected tags
- Entry detail view shows all 3 tags as chips

**Validation**:
- Check Database → `entry_tags` table:
  - 3 records exist for this `entry_id`, linking to the 3 tag IDs
- Smart Page color theme should prioritize "Nature & Hiking" → `earth_green`

#### Test Case 4.5.3: Tag-Based Color Theme Mapping

**Test Matrix**: Create entries with different tag combinations and verify color theme

| Tags | Expected Color Theme | Rationale |
|------|---------------------|-----------|
| "Romantic Moments", "In Love" | `warm_red` | Romantic priority |
| "Nature & Hiking" | `earth_green` | Nature priority |
| "Lake / Beach" | `ocean_blue` | Beach/water priority |
| "Nightlife" | `deep_purple` | Nightlife priority |
| "Food & Restaurant" | `warm_earth` | Food priority |
| "Travel" | `soft_rose` | Travel priority |
| "Happy" (only emotion, no activity) | Fallback to photo dominant color or `neutral` | No specific theme |
| No tags | `neutral` | Default fallback |

**Steps for Each Row**:
1. Create entry with specified tags
2. Wait for Smart Page computation (a few seconds)
3. View entry detail
4. Check "Color Theme" field

**Expected Results**:
- Color theme matches the expected value from the table
- Entry detail view or flipbook page uses the correct color palette

---

### 4.6 Flipbook Viewer

**Feature**: 3D page-turn animation viewer for entries

**Preconditions**: User is logged in, a log exists with at least 3 entries

#### Test Case 4.6.1: Open Flipbook

**Steps**:
1. Navigate to logs list
2. Click on a log that has multiple entries (create 3-5 test entries if needed)
3. Click "View Flipbook" button

**Expected Results**:
- App navigates to `/logs/{logId}/flipbook`
- Flipbook viewer loads
- First entry is displayed as a page spread
- 3D-like page-turn animation component is visible
- Navigation controls (arrows, swipe hints) are present

#### Test Case 4.6.2: Navigate Forward (Next Page)

**Steps**:
1. In flipbook viewer, click "Next" button or swipe left (touch gesture)

**Expected Results**:
- Page-turn animation plays (3D flip effect)
- Next entry's page is displayed
- Animation is smooth (60 fps target)
- Content loads without lag

#### Test Case 4.6.3: Navigate Backward (Previous Page)

**Steps**:
1. After navigating to page 2 or beyond, click "Previous" button or swipe right

**Expected Results**:
- Page-turn animation plays in reverse
- Previous entry's page is displayed
- Animation is smooth

#### Test Case 4.6.4: View Entry with Different Layout Types

**Setup**: Create entries with varying photo counts to trigger different layouts
- Entry 1: 1 photo → `single_full`
- Entry 2: 3 photos → `grid_2x2`
- Entry 3: 6 photos → `grid_3x2`

**Steps**:
1. Open flipbook
2. Navigate through all 3 entries
3. Observe page layouts

**Expected Results**:
- **Entry 1 (single_full)**: Large hero photo, text below or overlaid
- **Entry 2 (grid_2x2)**: 2x2 grid of photos, text in available space
- **Entry 3 (grid_3x2)**: 3x2 grid showing all 6 photos, compact text

#### Test Case 4.6.5: Color Theme Application in Flipbook

**Setup**: Create entries with different tags to trigger different color themes
- Entry A: "Romantic Moments" → `warm_red` theme
- Entry B: "Beach" → `ocean_blue` theme
- Entry C: "Nature & Hiking" → `earth_green` theme

**Steps**:
1. Open flipbook
2. Navigate through all 3 entries
3. Observe page color schemes

**Expected Results**:
- Each page uses its computed color theme
- Background, text color, and accents match the theme
- Smooth color transitions between pages

#### Test Case 4.6.6: Sprinkles Display

**Setup**: Create an entry with tags that trigger sprinkles:
- Tags: "Romantic Moments", "Travel", "Happy"
- Expected sprinkles: heart (romantic), airplane (travel), star (happy) → max 3

**Steps**:
1. Open flipbook and navigate to this entry's page
2. Observe decorative icons (sprinkles)

**Expected Results**:
- Up to 3 sprinkles are displayed on the page
- Icons are positioned aesthetically (corners, edges, overlays)
- Icons match the selected tags

#### Test Case 4.6.7: Flipbook Performance with 50+ Entries

**Setup**: Create a log with 50+ entries (use bulk test data or script)

**Steps**:
1. Open flipbook for this log
2. Navigate through multiple pages
3. Observe performance

**Expected Results**:
- Initial load time < 3 seconds
- Page-turn animation remains smooth (no frame drops)
- No memory leaks (check browser dev tools)
- App does not crash or freeze

#### Test Case 4.6.8: Flipbook on Web (Mouse Interactions)

**Steps**:
1. Open flipbook in Chrome/Brave browser
2. Test mouse interactions:
   - Click left edge → previous page
   - Click right edge → next page
   - Click and drag → page-turn animation follows cursor

**Expected Results**:
- All mouse interactions work as expected
- Click zones are intuitive
- Drag gesture feels natural

---

### 4.7 Smart Pages Engine (Backend)

**Feature**: Backend-computed layout type, color theme, and sprinkles

**Preconditions**: Entry created with photos and tags

#### Test Case 4.7.1: Verify Layout Type Computation

**Test Matrix**:

| Photo Count | Expected Layout Type |
|-------------|---------------------|
| 0 | `single_full` |
| 1 | `single_full` |
| 2 | `grid_2x2` |
| 3 | `grid_2x2` |
| 4 | `grid_2x2` |
| 5 | `grid_3x2` |
| 6 | `grid_3x2` |

**Steps for Each Row**:
1. Create entry with specified photo count
2. Wait for Smart Page computation (check `is_processed` flag)
3. Query database or view entry detail

**Expected Results**:
- `page_layout_type` matches expected value

**Validation**:
```bash
# Query database
supabase db sql "SELECT id, page_layout_type, is_processed FROM entries WHERE id = 'entry-uuid';"
```

#### Test Case 4.7.2: Verify Color Theme Priority Rules

**Test Matrix** (see Section 4.5.3 for detailed matrix)

**Steps**:
1. Create entries with different tag combinations
2. Verify color theme follows priority rules:
   - Priority 1: Romantic → `warm_red`
   - Priority 2: Nature → `earth_green`
   - Priority 3: Beach → `ocean_blue`
   - Priority 4: Nightlife → `deep_purple`
   - Priority 5: Food → `warm_earth`
   - Priority 6: Travel → `soft_rose`
   - Fallback: Dominant photo color or `neutral`

**Expected Results**:
- Color theme matches the highest-priority tag present

#### Test Case 4.7.3: Verify Sprinkles Selection

**Test Matrix**:

| Tags | Expected Sprinkles (up to 3) |
|------|------------------------------|
| "Romantic Moments" | heart |
| "Nature & Hiking" | mountain |
| "Lake / Beach" | beach icon |
| "Travel" | airplane |
| "Food & Restaurant" | utensils |
| "Birthday" | balloon |
| "Happy" | star |
| Multiple tags | Up to 3 icons based on tag priority |

**Steps**:
1. Create entry with specified tags
2. Wait for Smart Page computation
3. Check `sprinkles` field in database

**Validation**:
```bash
supabase db sql "SELECT sprinkles FROM entries WHERE id = 'entry-uuid';"
```
- Output should be a JSONB array, e.g., `["heart", "airplane", "star"]`

#### Test Case 4.7.4: Verify is_processed Flag

**Steps**:
1. Create a new entry
2. Immediately query the database for `is_processed` flag
3. Wait 5-10 seconds
4. Query again

**Expected Results**:
- Initially: `is_processed = false`
- After workers complete: `is_processed = true`

**Validation**:
```bash
supabase db sql "SELECT id, is_processed, page_layout_type, color_theme FROM entries WHERE id = 'entry-uuid';"
```

---

### 4.8 Location Handling

**Feature**: GPS-based reverse geocoding and manual location override

**Preconditions**: Entry created with or without location data

#### Test Case 4.8.1: Automatic Location from EXIF GPS

**Steps**:
1. Upload a photo with EXIF GPS data during entry creation
2. Leave location field empty
3. Create entry
4. Wait for reverse geocoding worker (5-10 seconds)
5. Refresh entry detail view

**Expected Results**:
- Entry's `location_display_name` is populated (e.g., "Tempelhofer Feld, Berlin, Germany")
- `location_lat` and `location_lng` match EXIF data
- `location_is_user_overridden = false`

**Validation**:
- Check Edge Function logs:
  ```bash
  supabase functions logs reverse-geocode
  ```
- Verify API call to Nominatim succeeded

#### Test Case 4.8.2: Manual Location Override

**Steps**:
1. Create entry with GPS-extracted location: "Berlin, Germany"
2. Edit entry
3. Change location to: "Brandenburg Gate, Berlin"
4. Check "Override Location" checkbox
5. Save entry

**Expected Results**:
- Location updates to "Brandenburg Gate, Berlin"
- `location_is_user_overridden = true`
- Future GPS data will NOT overwrite this location

**Validation**:
```bash
supabase db sql "SELECT location_display_name, location_is_user_overridden FROM entries WHERE id = 'entry-uuid';"
```

#### Test Case 4.8.3: No Location (Photo without GPS)

**Steps**:
1. Upload a photo without EXIF GPS data
2. Leave location field empty
3. Create entry

**Expected Results**:
- Entry is created successfully
- `location_lat` and `location_lng` are NULL
- `location_display_name` is empty or NULL
- No reverse geocoding worker is triggered

---

### 4.9 Row Level Security (Multi-User Testing)

**Feature**: RLS policies enforce data isolation between users

**Preconditions**: 2 test users created (User A, User B)

#### Test Case 4.9.1: User A Cannot Access User B's Logs

**Steps**:
1. Log in as **User A**
2. Create a log: "User A's Log"
3. Log out
4. Log in as **User B**
5. Navigate to `/logs`

**Expected Results**:
- User B's logs list does NOT show "User A's Log"
- Only User B's own logs are visible

**Validation (Database Query)**:
```bash
# Set auth context to User B's ID
supabase db sql "SET request.jwt.claims.sub = 'user-b-uuid'; SELECT * FROM logs;"
```
- Only User B's logs returned

#### Test Case 4.9.2: User B Cannot Edit User A's Entry (Direct API Call)

**Steps**:
1. Obtain an entry ID from User A's account
2. Log in as User B
3. Attempt to edit the entry via API:
   ```bash
   curl -X PATCH https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/entries/{user-a-entry-id} \
     -H "Authorization: Bearer USER_B_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"highlight_text": "Hacked by User B"}'
   ```

**Expected Results**:
- API returns `403 Forbidden` or `404 Not Found`
- Entry is NOT updated
- Database record remains unchanged

#### Test Case 4.9.3: User A Cannot Access User B's Photos (Storage)

**Steps**:
1. Obtain a photo path from User B's account: `photos/user-b-uuid/photo-123.jpg`
2. Log in as User A
3. Attempt to access the photo URL directly in browser

**Expected Results**:
- Access denied (403 or authentication error)
- Photo is not displayed

**Note**: Supabase Storage RLS policies enforce folder-based access (`{user_id}/*`).

---

### 4.10 Complete User Journey (End-to-End)

**Test Scenario**: New user creates a complete memory book

**Steps**:
1. **Sign Up**: Create account `journey-test@example.com`
2. **Create Log**: "Our 2024 Road Trip" (Type: Couple)
3. **Create Entry 1**:
   - Date: June 1, 2024
   - Photos: 2 landscape photos
   - Highlight: "Started our journey in Berlin"
   - Tags: "Roadtrip", "Happy"
   - Location: "Berlin, Germany"
4. **Create Entry 2**:
   - Date: June 3, 2024
   - Photos: 4 photos
   - Highlight: "Beach day in Barcelona"
   - Tags: "Lake / Beach", "Travel", "Relaxed"
   - Location: Leave empty (test GPS extraction if photos have EXIF)
5. **Create Entry 3**:
   - Date: June 5, 2024
   - Photos: 1 photo
   - Highlight: "Romantic dinner in Paris"
   - Tags: "Romantic Moments", "Food & Restaurant"
   - Location: "Paris, France"
6. **View Entries List**: Navigate to "Our 2024 Road Trip" → Entries
   - Verify all 3 entries appear in chronological order
7. **Edit Entry 2**: Change highlight text to "Amazing beach day in Barcelona"
8. **View Flipbook**: Click "View Flipbook"
   - Navigate through all 3 pages
   - Verify:
     - Entry 1: `grid_2x2` layout, theme based on "Roadtrip"
     - Entry 2: `grid_2x2` layout, `ocean_blue` theme (Beach tag)
     - Entry 3: `single_full` layout, `warm_red` theme (Romantic tag)
   - Test page-turn animations
9. **Delete Entry 1**: Go back to entries list, delete "Started our journey in Berlin"
10. **Verify Deletion**: Re-open flipbook, verify only 2 entries remain
11. **Sign Out**: Log out
12. **Sign In**: Log back in, verify data persists

**Expected Results**:
- All operations complete successfully
- Data persists across sessions
- Smart Pages compute correctly for each entry
- Flipbook displays entries with correct layouts and themes
- No errors occur during the journey

---

## 5. Backend/API & Database Checks

### 5.1 REST API Endpoint Testing

Use `curl` or Postman to test backend endpoints directly.

#### 5.1.1 Obtain Auth Token

**Steps**:
1. Sign in via Flutter app
2. Extract JWT token from browser:
   - Open browser DevTools → Application → Local Storage
   - Look for `supabase.auth.token` or similar
   - Copy the access token

Alternatively, sign in via Supabase API:
```bash
curl -X POST https://ikspskghylahtexiqepl.supabase.co/auth/v1/token?grant_type=password \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```
- Extract `access_token` from response

#### 5.1.2 Test Logs API

**GET /api-logs** - List all logs
```bash
curl -X GET https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-logs \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK`
- JSON array of logs:
  ```json
  [
    {
      "id": "uuid",
      "user_id": "uuid",
      "name": "Our Memories",
      "type": "Couple",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
  ```

**POST /api-logs** - Create log
```bash
curl -X POST https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-logs \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Log via API",
    "type": "Friends"
  }'
```
**Expected**:
- Status: `201 Created`
- JSON with new log details

**PATCH /api-logs/:id** - Update log
```bash
curl -X PATCH https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-logs/LOG_UUID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Log Name"}'
```
**Expected**:
- Status: `200 OK`
- JSON with updated log

**DELETE /api-logs/:id** - Delete log
```bash
curl -X DELETE https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-logs/LOG_UUID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK` or `204 No Content`

#### 5.1.3 Test Entries API

**GET /api-entries/tags** - List all tags
```bash
curl -X GET https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/tags \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK`
- JSON array of 19 tags:
  ```json
  [
    {"id": "uuid", "name": "Nature & Hiking", "category": "activity", "icon": "mountain"},
    ...
  ]
  ```

**GET /api-entries/logs/:logId/entries** - List entries for a log
```bash
curl -X GET https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/logs/LOG_UUID/entries \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK`
- JSON array of entries with photos and tags

**POST /api-entries/logs/:logId/entries** - Create entry
```bash
curl -X POST https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/logs/LOG_UUID/entries \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event_date": "2024-06-15T12:00:00Z",
    "highlight_text": "Beach day",
    "location_display_name": "Santa Monica",
    "tag_ids": ["tag-uuid-1", "tag-uuid-2"]
  }'
```
**Expected**:
- Status: `201 Created`
- JSON with new entry details

**GET /api-entries/entries/:id** - Get entry details
```bash
curl -X GET https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/entries/ENTRY_UUID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK`
- JSON with full entry details, photos array, tags array

**PATCH /api-entries/entries/:id** - Update entry
```bash
curl -X PATCH https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/entries/ENTRY_UUID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"highlight_text": "Updated text"}'
```
**Expected**:
- Status: `200 OK`

**DELETE /api-entries/entries/:id** - Delete entry
```bash
curl -X DELETE https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries/entries/ENTRY_UUID \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```
**Expected**:
- Status: `200 OK` or `204 No Content`

#### 5.1.4 Test Worker Functions

**Note**: Workers are typically triggered automatically, but can be invoked directly for testing.

**POST /compute-smart-page** - Compute Smart Page
```bash
curl -X POST https://ikspskghylahtexiqepl.supabase.co/functions/v1/compute-smart-page \
  -H "Authorization: Bearer SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"entry_id": "ENTRY_UUID"}'
```
**Expected**:
- Status: `200 OK`
- Entry's Smart Page fields are updated (`page_layout_type`, `color_theme`, `sprinkles`, `is_processed = true`)

**POST /reverse-geocode** - Reverse geocode GPS coordinates
```bash
curl -X POST https://ikspskghylahtexiqepl.supabase.co/functions/v1/reverse-geocode \
  -H "Authorization: Bearer SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "entry_id": "ENTRY_UUID",
    "lat": 52.5200,
    "lng": 13.4050
  }'
```
**Expected**:
- Status: `200 OK`
- Entry's `location_display_name` is set (e.g., "Berlin, Germany")

### 5.2 Database Verification (SQL Queries)

Use Supabase CLI or Dashboard SQL Editor to verify data.

#### 5.2.1 Check Logs Table

```sql
SELECT id, user_id, name, type, created_at FROM logs ORDER BY created_at DESC LIMIT 10;
```
**Expected**: List of logs for various users

#### 5.2.2 Check Entries Table

```sql
SELECT id, log_id, event_date, highlight_text, page_layout_type, color_theme, is_processed
FROM entries
ORDER BY event_date DESC
LIMIT 10;
```
**Expected**: List of entries with Smart Page fields populated

#### 5.2.3 Check Photos Table

```sql
SELECT id, entry_id, storage_path, url, thumbnail_url, dominant_colors
FROM photos
LIMIT 10;
```
**Expected**: List of photos with storage paths and URLs

#### 5.2.4 Check Entry Tags Relationship

```sql
SELECT e.id AS entry_id, e.highlight_text, t.name AS tag_name, t.category
FROM entries e
JOIN entry_tags et ON e.id = et.entry_id
JOIN tags t ON et.tag_id = t.id
LIMIT 20;
```
**Expected**: Entries with their associated tags

#### 5.2.5 Check RLS Policies

```sql
-- List RLS policies for logs table
SELECT * FROM pg_policies WHERE tablename = 'logs';
```
**Expected**: Policies for SELECT, INSERT, UPDATE, DELETE with `auth.uid()` checks

#### 5.2.6 Verify Smart Page Computation

```sql
SELECT id, highlight_text, page_layout_type, color_theme, sprinkles, is_processed
FROM entries
WHERE is_processed = true
LIMIT 10;
```
**Expected**: Entries with Smart Page fields populated and `is_processed = true`

### 5.3 Storage Verification

#### 5.3.1 Check Photos Bucket

1. Navigate to Supabase Dashboard → Storage → `photos` bucket
2. Browse folders (organized by `user_id`)
3. Verify files exist for uploaded photos

**Expected**:
- Files present at paths like `{user_id}/{photo_uuid}.jpg`
- Files are accessible (click to view)

#### 5.3.2 Check Thumbnails Bucket

1. Navigate to Supabase Dashboard → Storage → `thumbnails` bucket
2. Verify thumbnail files exist

**Expected** (V1 Limitation):
- Thumbnails may be placeholders or empty (full thumbnail generation requires image processing libraries, noted in `process-photo` worker)

### 5.4 Edge Function Logs

View logs to debug issues:

```bash
# View logs for specific function
supabase functions logs api-logs
supabase functions logs api-entries
supabase functions logs compute-smart-page
supabase functions logs reverse-geocode
```

**Expected**: No errors in recent logs (or only expected validation errors)

---

## 6. Regression Testing Per Milestone

This section maps test cases to completed milestones. After any code change, re-run tests for affected milestones.

### Milestone 3: Database Schema
- **Test**: 5.2.1 - 5.2.6 (SQL queries)
- **Verify**: Tables exist, RLS policies active, seed data present

### Milestone 4: Logs REST API
- **Test**: 5.1.2 (Logs API endpoints)
- **Verify**: All CRUD operations work

### Milestone 5: Entries REST API
- **Test**: 5.1.3 (Entries API endpoints)
- **Verify**: All CRUD operations work, photos and tags linked

### Milestone 6: Worker Functions
- **Test**: 4.8.1 (GPS extraction), 5.1.4 (Worker APIs)
- **Verify**: Reverse geocoding works, photo processing runs

### Milestone 7: Smart Pages Engine
- **Test**: 4.7.1 - 4.7.4 (Smart Page computation)
- **Verify**: Layout type, color theme, sprinkles computed correctly

### Milestone 8: Flutter Auth UI
- **Test**: 4.1.1 - 4.1.5 (Auth flow)
- **Verify**: Signup, login, logout, session persistence work

### Milestone 9: Flutter Logs Feature
- **Test**: 4.2.1 - 4.2.5 (Logs CRUD)
- **Verify**: Create, read, update, delete logs in Flutter app

### Milestone 10: Flutter Entries Feature
- **Test**: 4.3.1 - 4.3.6 (Entries CRUD), 4.4.1 - 4.4.4 (Photo upload), 4.5.1 - 4.5.3 (Tags)
- **Verify**: Entry creation with photos, tag selection, location editing

### Milestone 11: Flipbook Viewer
- **Test**: 4.6.1 - 4.6.8 (Flipbook navigation and rendering)
- **Verify**: Page-turn animation, layout rendering, color themes, sprinkles display

### Milestone 12: Integration Testing (Upcoming)
- **Test**: 4.10 (Complete user journey), all sections
- **Verify**: Full end-to-end flow works

---

## 7. Known Limitations / Out of Scope

### 7.1 Platform Constraints (MANDATORY)

**Web Only**: TogetherLog V1 is tested exclusively on **Flutter Web**.

**Prohibited Testing Platforms**:
- Windows desktop
- macOS desktop
- Linux desktop
- Android devices
- iOS devices
- Web Server device

**Reason**: Development and testing focus is Web-first for V1 MVP.

### 7.2 V1 Feature Limitations

Features NOT implemented in V1 (see `docs/v2optional.md`):
- **Map View**: Interactive maps with entry markers
- **Story Slideshow**: Auto-advancing slideshow mode
- **Sprinkles UI**: V1 computes sprinkles, but UI rendering may be minimal
- **AI-Assisted Smart Pages**: V1 uses deterministic rules only
- **Offline Mode**: App requires internet connection
- **Multi-User Collaboration**: Logs have single owners
- **PDF Export**: Not implemented in V1
- **Advanced Layouts**: Only `single_full`, `grid_2x2`, `grid_3x2` in V1

### 7.3 Known V1 Issues

- **Photo Editing**: Cannot replace or reorder photos after entry creation
- **EXIF Extraction**: Limited in V1 (placeholder implementation in `process-photo` worker)
- **Thumbnail Generation**: Placeholder implementation (requires image processing library)
- **Color Extraction**: Placeholder implementation (requires image analysis library)
- **Large Flipbooks**: Performance not optimized for 100+ entries yet
- **Accessibility**: V1 has basic accessibility, not fully WCAG 2.1 compliant

### 7.4 Browser Compatibility

**Tested Browsers**:
- Brave (primary)
- Chrome (fallback)

**Not Tested**:
- Firefox
- Safari
- Edge

**Note**: Flutter Web best supports Chrome/Chromium-based browsers. Other browsers may have rendering or performance issues.

### 7.5 Mobile Responsiveness

**V1 Status**: Basic responsive design implemented.

**Known Issues**:
- Some UI elements may not scale perfectly on small screens (< 360px width)
- Touch gestures may not work perfectly on all mobile browsers

**Recommendation**: Test primarily on desktop browsers (1920x1080 or 1366x768 resolutions) for V1.

---

## 8. Troubleshooting Common Issues

### Issue: Auth token expired

**Symptoms**: API calls return `401 Unauthorized`

**Solution**:
1. Log out and log back in
2. Obtain fresh access token
3. Update curl commands with new token

### Issue: Photos not uploading

**Symptoms**: Upload progress bar stuck, error message appears

**Possible Causes**:
- Network connection issue
- Supabase Storage quota exceeded
- File size too large (> 50 MB)

**Solution**:
1. Check network connection
2. Check Supabase Dashboard → Storage → Usage
3. Try uploading smaller images

### Issue: Smart Page fields not populating

**Symptoms**: `is_processed` remains `false`, layout type is `null`

**Possible Causes**:
- Worker function not triggered
- Worker function error

**Solution**:
1. Check Edge Function logs:
   ```bash
   supabase functions logs compute-smart-page
   ```
2. Manually trigger worker via API (Section 5.1.4)
3. Check database for entry ID validity

### Issue: Flipbook animation stuttering

**Symptoms**: Page-turn animation is laggy or drops frames

**Possible Causes**:
- Large image files not optimized
- Browser performance limitations
- Too many entries (> 100)

**Solution**:
1. Test with smaller image files
2. Close other browser tabs
3. Test on a different device with better specs

### Issue: RLS policy blocking legitimate access

**Symptoms**: User cannot access their own data, API returns `403` or `404`

**Possible Causes**:
- Auth token not passed correctly
- RLS policy misconfigured

**Solution**:
1. Verify `Authorization: Bearer TOKEN` header in API calls
2. Check RLS policies in Supabase Dashboard → Database → Policies
3. Test with service role key (bypass RLS) to confirm data exists

---

## 9. Reporting Bugs

When reporting bugs, include:
1. **Test Case Number**: Reference this guide (e.g., "Test Case 4.3.1")
2. **Steps to Reproduce**: Exact actions taken
3. **Expected Result**: What should have happened
4. **Actual Result**: What actually happened
5. **Screenshots**: If UI issue
6. **Browser/Device**: Browser version, OS
7. **Logs**: Relevant Edge Function logs or browser console errors

Report bugs at: https://github.com/anthropics/claude-code/issues (or project-specific repo)

---

## 10. Testing Sign-Off Checklist

Before marking a milestone or release as "tested":

- [ ] All test cases in Section 4 executed
- [ ] API endpoints tested (Section 5.1)
- [ ] Database queries verified (Section 5.2)
- [ ] RLS policies validated (Section 4.9)
- [ ] Complete user journey tested (Section 4.10)
- [ ] Edge Function logs reviewed (no errors)
- [ ] Known limitations documented
- [ ] Regression tests for previous milestones passed
- [ ] Test results documented (spreadsheet, test management tool, or commit message)

---

## Appendix A: Test Data Preparation

### A.1 Seed Tags (Preloaded)

The following 19 tags should exist in the database (from migration `001_initial_schema.sql`):

**Activity (9)**:
- Nature & Hiking
- Lake / Beach
- City & Sightseeing
- Food & Restaurant
- Home & Everyday Life
- Adventure / Sports
- Nightlife
- Roadtrip
- Romantic Moments

**Event (5)**:
- Anniversary
- Birthday
- Holiday / Celebration
- Travel
- Surprise / Gift

**Emotion (5)**:
- Happy
- Relaxed
- Proud
- In Love
- Silly / Fun

### A.2 Test Images

Prepare test images with varying properties:
1. **Landscape with EXIF GPS**: Photo taken with smartphone (contains GPS coordinates)
2. **Portrait with EXIF GPS**: Same as above
3. **Image without EXIF**: Stock photo or edited image with metadata stripped
4. **Large image**: 8 MB, 4000x3000 pixels
5. **Small image**: 500 KB, 1024x768 pixels
6. **Non-image file**: PDF, TXT (for negative testing)

### A.3 Sample Test Scenarios

For bulk testing, use these pre-defined scenarios:

**Scenario 1: Couple Road Trip**
- Log: "Our 2024 Road Trip" (Couple)
- Entry 1: "Berlin start", 2 photos, tags: Roadtrip, Happy
- Entry 2: "Prague castle", 4 photos, tags: City & Sightseeing, Travel
- Entry 3: "Vienna coffee", 1 photo, tags: Food & Restaurant, Relaxed

**Scenario 2: Friends Beach Vacation**
- Log: "Summer 2024 Getaway" (Friends)
- Entry 1: "Arrived at beach", 3 photos, tags: Lake / Beach, Travel
- Entry 2: "Beach volleyball", 5 photos, tags: Adventure / Sports, Silly / Fun
- Entry 3: "Sunset dinner", 2 photos, tags: Food & Restaurant, Relaxed

**Scenario 3: Family Celebration**
- Log: "Mom's 60th Birthday" (Family)
- Entry 1: "Surprise party", 6 photos, tags: Birthday, Surprise / Gift, Happy
- Entry 2: "Cake cutting", 1 photo, tags: Birthday, Happy
- Entry 3: "Family photo", 4 photos, tags: Family, Proud

---

## Appendix B: Performance Benchmarks

Target performance metrics for V1:

| Metric | Target | Acceptable | Critical |
|--------|--------|-----------|----------|
| API response time (95th percentile) | < 500ms | < 1s | < 3s |
| Photo upload time (2 MB image) | < 3s | < 5s | < 10s |
| Flipbook initial load (10 entries) | < 2s | < 3s | < 5s |
| Page-turn animation FPS | 60 fps | 45 fps | 30 fps |
| Web build size (gzipped) | < 5 MB | < 10 MB | < 20 MB |

If actual performance exceeds "Critical" threshold, investigate and optimize before release.

---

## Appendix C: Supabase Dashboard Quick Links

For manual verification:

- **Auth Users**: Dashboard → Authentication → Users
- **Database Tables**: Dashboard → Database → Tables
- **Storage Buckets**: Dashboard → Storage
- **Edge Functions**: Dashboard → Edge Functions
- **Logs**: Dashboard → Logs (filter by function name)
- **SQL Editor**: Dashboard → SQL Editor

---

**End of Testing Guide**
