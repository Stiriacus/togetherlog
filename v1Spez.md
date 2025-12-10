# TogetherLog — Version 1 Specification (MVP)

## 1. Overview
TogetherLog is an online platform for couples and close groups to record shared memories as a beautiful, interactive flipbook.  
Users can upload photos, add dates, set locations, assign tags, and write short highlight notes.  
A Smart Page system automatically creates visually appealing memory pages using rules and templates.

This MVP focuses on core creation, display, and organization features for the digital memory book.

---

## 2. Core User Concepts

### 2.1 User Account
- Email + password registration and login.
- Each user can create and manage multiple logs.

### 2.2 Logs (Memory Books)
Each log represents a shared timeline of events.
- Log name.
- Log type (Couple, Friends, Family) — cosmetic only.
- Owner only (multi-user collaboration may be added later).

---

## 3. Entries (Core Data Record)
An entry represents a single memory event.

### 3.1 Entry Fields
- `id`
- `log_id`
- `event_date`
- `highlight_text`
- `photos[]` (one or many)
- `tags[]` (from predefined categories)
- `location`:
  - `lat`, `lng` (optional)
  - `display_name`
  - `is_user_overridden` (boolean)
- `page_layout_type` (auto-selected)
- `color_theme` (auto-selected)
- Optional (data structure ready, not yet displayed):
  - `sprinkles[]`

### 3.2 Photo Handling
- Upload 1–N photos per entry.
- EXIF extraction:
  - Date used as default `event_date`
  - GPS used for location lookup
- Automatic thumbnail generation.

---

## 4. Tags (Categories)
Tags represent thematic categories for memory entries.  
All stored as tag records in a DB and attached through a many-to-many relation.

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

---

## 5. Location Handling

### 5.1 Automatic
- Read EXIF GPS coordinates if present.
- Reverse geocode via OpenStreetMap/Nominatim.

### 5.2 Manual Editing
Users may:
- Override the detected location name.
- Set coordinates manually via map search.
- Marking `is_user_overridden = true` stops future automatic updates.

---

## 6. Smart Pages (Rule-Based)

### 6.1 Purpose
Automatically generate visually consistent and aesthetic memory pages.

### 6.2 Inputs
- Number of photos
- Tags
- Highlight text length
- Location availability
- Basic emotional hints (derived from tags)

### 6.3 Layout Rules
- 1 photo → hero/single layout
- 2–4 photos → grid/collage layout
- More photos → capped layout with optional overflow handling

### 6.4 Color Theme Rules (Emotion-Color-Engine V1)
- Romantic → warm reds / soft rose
- Nature → greens / earth tones
- Beach → blue / turquoise
- Nightlife → dark blue / purple
- Other → derived from dominant image color with neutral fallback

### 6.5 Optional Elements (data only)
- Polaroid frame style
- Collage layout variations
- Sprinkles (icons based on category)

These are not active UI features yet, but the data structure allows easy enablement in the future.

---

## 7. Flipbook Viewer (Primary Display Mode)
- Chronological display of entries.
- Page-flip animation between entries.
- Simple navigation:
  - Next/previous buttons
  - Keyboard arrows
- Each entry displayed as a full page.

---

## 8. Non-Functional Requirements

### 8.1 Performance
- Load flipbook pages lazily.
- Cache thumbnails for fast rendering.

### 8.2 Storage
- Photos stored in local or S3-compatible object storage.
- Thumbnails stored separately.

### 8.3 Security
- Basic authentication.
- Users can only access their own logs.

---

## 9. Out of Scope for V1 (but prepared in structure)
- Map view  
- Story slideshow  
- Heatmaps  
- Widget integrations  
- Multi-user collaboration  
- Full AI-based Smart Page enhancements  

---

## 10. Goal of V1
A polished, smooth, emotionally pleasant memory-book creation tool  
with automated page design, reliable data entry, and beautiful flipbook playback.
