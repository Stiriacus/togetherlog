# TogetherLog — Version 1 Specification (MVP)

## 1. Overview

TogetherLog is an online platform for couples and close groups to record shared memories as a beautiful, interactive flipbook.

Target platforms for V1:
- **Flutter Web**
- **Flutter Android**

Users can:
- Upload photos
- Add dates
- Set or correct locations
- Assign tags from a predefined set
- Write short highlight notes

A client-side **Smart Page** system automatically creates visually appealing memory pages using rules and templates. Users can optionally customize layouts through an interactive editor. The backend serves as persistent storage for final layouts.

The MVP is **online-only** (no offline mode).

---

## 2. Core User Concepts

### 2.1 User Account
- Email + password registration and login.
- Optionally OAuth (e.g., Google, Apple) in addition to email/password.
- Each user can create and manage multiple logs.

### 2.2 Logs (Memory Books)
Each log represents a shared timeline of events.

- Log name.
- Log type (e.g., Couple, Friends, Family) — cosmetic only.
- Single owner in V1 (multi-user collaboration may be added later).

---

## 3. Entries (Core Data Record)

An entry represents a single memory event belonging to one log.

### 3.1 Entry Fields (Conceptual Model)

- `id`
- `log_id`
- `created_at`
- `updated_at`
- `event_date` (date of the moment)
- `highlight_text` (short description)
- `photos[]`
  - `photo_id`
  - `url`
  - `thumbnail_url`
  - optional metadata (EXIF, dominant color, etc.)
- `tags[]` (references to predefined tag records)
- `location`
  - `lat` (optional)
  - `lng` (optional)
  - `display_name` (e.g., "Berlin, Tempelhofer Feld")
  - `is_user_overridden` (boolean)
- `custom_layout` (JSONB containing client-computed or user-customized layout data)
  - Includes: `page_layout_type`, `color_theme`, `sprinkles[]`, item positions, decorations
- `is_customized` (boolean - whether user has manually edited the page)

### 3.2 Photo Handling

- Upload 1–N photos per entry.
- The backend:
  - Accepts the upload.
  - Stores photos in **object storage** (S3-compatible), ideally in an **EU region** for GDPR/DSGVO.
  - Generates and stores thumbnails.
  - Extracts EXIF metadata when available:
    - Date/time (can be used as default `event_date`)
    - GPS coordinates (used for location lookup)
- The client:
  - Computes Smart Page layout based on photos, tags, and entry data
  - Optionally allows user to customize layout via interactive editor
  - Sends final layout to backend for storage

The Flutter client communicates with the backend via HTTP/JSON and does not manage persistent local storage for V1 (no Isar/Hive needed initially).

---

## 4. Tags (Categories)

Tags represent thematic categories for memory entries.  
They are stored in a `tags` table and linked to entries via a many-to-many relation.

### 4.1 Initial Tag Set

- Nature & Hiking  
- Lake / Beach  
- City & Sightseeing  
- Food & Restaurant  
- Home & Everyday Life  
- Adventure / Sports  
- Nightlife  
- Roadtrip  
- Romantic Moments  

- Anniversary  
- Birthday  
- Holiday / Celebration  
- Travel  
- Surprise / Gift  

- Happy  
- Relaxed  
- Proud  
- In Love  
- Silly / Fun  

Tags will be attached to entries as an array of references and can be filtered against in later features (e.g., timelines, map view).

---

## 5. Location Handling

### 5.1 Automatic Detection

On photo upload, the backend:

- Reads EXIF GPS coordinates if present.
- Performs reverse geocoding (e.g., using OpenStreetMap/Nominatim or a similar open provider).
- Stores:
  - `lat`, `lng`
  - `display_name` (human-readable location)

The client uses location data (along with photos and tags) to compute Smart Page layouts.

### 5.2 Manual Editing

In the Flutter app, the user can:

- Edit the human-readable `display_name`.
- Set or adjust coordinates via a location input (e.g., search box / map picker, can come later).
- Mark the location as user-corrected via `is_user_overridden = true`.

If `is_user_overridden = true`, the backend will not overwrite the location automatically on future updates.

The client uses location data (along with photos and tags) to compute Smart Page layouts.

---

## 6. Smart Pages (Client-Side, Rule-Based with Optional Customization)

### 6.1 Purpose

Smart Pages automatically generate visually consistent and aesthetic memory pages so that the user does not need to manually design layouts. Users can optionally customize layouts through an interactive editor.

### 6.2 Where It Runs

- The **client (Flutter)** computes:
  - `page_layout_type`
  - `color_theme`
  - `sprinkles[]` (icon sets or decorations)
  - Item positions, sizes, and rotations
  - Optional decorations and customizations
- The **backend** stores the final layout as JSONB without validation
- Users can enter an interactive editor to customize any auto-generated layout

### 6.3 Inputs to Smart Page Logic

- Number of photos
- Tags
- Highlight text length
- Location availability
- Basic emotional hints derived from tags (e.g., Romantic, Nature, Nightlife)

### 6.4 Layout Rules (Examples)

- 1 photo → hero/single layout (large photo, text below or overlaid).
- 2–4 photos → grid/collage layout.
- More photos → maximum number of displayed photos (e.g., 6), with possible "show more" or secondary layouts later.

The Smart Page engine returns a `page_layout_type` that the client understands (e.g., `single_full`, `grid_2x2`, `polaroid_grid`).

### 6.5 Color Theme Rules (Emotion-Color-Engine V1)

Basic, rule-based color theme mapping:

- Romantic / In Love / Romantic Moments → warm reds / soft rose.
- Nature & Hiking → greens / earth tones.
- Lake / Beach → blues / turquoise.
- Nightlife → dark blue / purple.
- Otherwise:
  - Client may derive a dominant color from the main photo.
  - Fallback to neutral, elegant themes.

The chosen color theme is returned as a `color_theme` identifier, which the Flutter app uses to build styles for that page. Global dark mode is planned for later versions and not required in V1.

### 6.6 Optional Layout & Decoration Data

The client may compute and store (even if UI doesn't render all yet):

- Polaroid-style frames.
- Collage patterns (e.g., stacked, overlapping).
- Sprinkles / decorative icons based on tags (hearts, mountains, beach symbols, etc.).

V1 can choose to ignore these in the UI while storing the data for future use.

---

## 7. Flipbook Viewer (Primary Display Mode)

### 7.1 Behavior

The flipbook is the main reading experience for a log:

- Shows all entries of a log in chronological order.
- Each entry is rendered as a full page using its Smart Page definition.
- Users can navigate between pages with a **3D-like page-turn animation**, mimicking a real book:
  - On Android: touch/swipe gestures.
  - On Web: mouse drag/click or swipe where supported.

The implementation may use an existing Flutter package or a custom animation, but the UX goal is:

- Natural feeling page flip.
- Smooth transitions.
- Good performance on Web + Android.

### 7.2 Navigation

- Forward/backward navigation (arrows / swipe).
- Optional quick jump to first/last entry.
- Future versions may include a timeline or thumbnail overview.

---

## 8. Backend & Storage (Conceptual)

### 8.1 Database

- **Relational database (PostgreSQL)** recommended.
- Deployed via:
  - Managed service (e.g., Supabase) with an EU region for GDPR compliance.
  - Or self-hosted PostgreSQL via Docker.

Core tables (conceptually):

- `users`
- `logs`
- `entries`
- `photos`
- `tags`
- `entry_tags`
- Optional helper tables for color presets, layout templates, etc.

### 8.2 Storage for Photos

- Object storage (S3-compatible), preferred in an EU region.
- Example setups:
  - Supabase Storage (managed, EU region).
  - MinIO / S3-compatible storage on a self-hosted server.
- Backend stores:
  - Raw images.
  - Thumbnails.
  - Optional derived metadata (dominant colors, EXIF, etc.).

### 8.3 Authentication

- Email + password.
- OAuth providers (e.g., Google/Apple) can be added as an additional login method.
- Standard JWT or session-based auth, depending on backend choice.

### 8.4 Smart Pages & Export

- The client computes Smart Page definitions and sends to backend for storage.
- Users can customize layouts through an interactive editor.
- Future: backend will handle:
  - PDF export.
  - Printable layouts.

---

## 9. Flutter Client Architecture

### 9.1 Stack

- Flutter for UI (Web + Android).
- State management: **Riverpod (flutter_riverpod)** for clean, testable state handling.
- HTTP client for backend communication (e.g., `dio` or `http`).

### 9.2 High-Level Structure

- Feature-based folder structure (e.g., `/features/logs`, `/features/entries`, `/features/auth`).
- Separation between:
  - Presentation (widgets/screens)
  - Application/state (Riverpod providers)
  - Infrastructure (API clients, models)

No local database for V1 — all data is loaded and persisted via network.

---

## 10. Non-Functional Requirements

### 10.1 Performance

- Lazy loading of entries/pages in flipbook.
- Thumbnails used in lists; full-size images in page view.
- Reasonable Web performance even on mid-level devices.

### 10.2 Security & Privacy

- Users can only access their own logs and entries.
- Photos stored in EU or GDPR-compliant regions when using managed services.
- Clear separation of user data, logs, and entries.

### 10.3 Deployment

- Monorepo structure:
  - `/app` for Flutter
  - `/backend` for API
  - `/docs` for specifications (this file, etc.)
- Self-hosting via Docker (especially for backend + DB).
- Optionally, hosting Flutter Web on Firebase Hosting or similar, if cost and region fit.

---

## 11. Out of Scope for V1 (but designed for)

- Offline mode.
- Map view.
- Story slideshow.
- Heatmaps.
- Widgets.
- Full AI-enhanced Smart Pages.
- Multi-user editing within the same log.

---

## 12. Goal of V1

Deliver a polished, online-only experience for creating and browsing shared memories:

- Clean Flutter client (Web + Android).
- Backend-driven Smart Pages.
- Beautiful, book-like 3D flipbook viewer.
- DSGVO-friendly architecture with EU-based storage and a path towards self-hosting and open source.
