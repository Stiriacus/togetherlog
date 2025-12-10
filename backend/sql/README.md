# TogetherLog - Database Schema Documentation

## Overview

This directory contains SQL migrations for the TogetherLog PostgreSQL database, designed to run on Supabase.

## Schema Architecture

### Core Tables

#### `public.logs`
Memory books - each user can create multiple logs.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key to auth.users (owner) |
| `name` | TEXT | Log name (1-100 chars) |
| `type` | TEXT | Log type: Couple, Friends, Family, Solo, Other |
| `created_at` | TIMESTAMP | Creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp (auto-updated) |

**RLS**: Users can only access their own logs.

---

#### `public.entries`
Individual memory entries within a log.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `log_id` | UUID | Foreign key to logs |
| `created_at` | TIMESTAMP | Creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp (auto-updated) |
| `event_date` | TIMESTAMP | Date of the memory event |
| `highlight_text` | TEXT | Short description (0-500 chars) |
| `location_lat` | DOUBLE PRECISION | GPS latitude (optional) |
| `location_lng` | DOUBLE PRECISION | GPS longitude (optional) |
| `location_display_name` | TEXT | Human-readable location |
| `location_is_user_overridden` | BOOLEAN | Whether user manually edited location |
| `page_layout_type` | TEXT | Smart Page layout (computed by backend) |
| `color_theme` | TEXT | Smart Page color theme (computed by backend) |
| `sprinkles` | JSONB | Decorative icons (computed by backend) |
| `is_processed` | BOOLEAN | Whether entry has been processed by workers |

**RLS**: Users can only access entries in their own logs.

---

#### `public.photos`
Photos attached to entries.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `entry_id` | UUID | Foreign key to entries |
| `storage_path` | TEXT | Path in Supabase Storage |
| `thumbnail_path` | TEXT | Thumbnail path in Supabase Storage |
| `url` | TEXT | Public URL (if applicable) |
| `thumbnail_url` | TEXT | Thumbnail URL |
| `exif_data` | JSONB | EXIF metadata (date, GPS, camera info) |
| `dominant_colors` | JSONB | Dominant colors extracted from image |
| `width` | INTEGER | Image width in pixels |
| `height` | INTEGER | Image height in pixels |
| `file_size` | BIGINT | File size in bytes |
| `mime_type` | TEXT | MIME type (e.g., image/jpeg) |
| `display_order` | INTEGER | Order within entry |
| `created_at` | TIMESTAMP | Creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**RLS**: Users can only access photos in their own entries.

---

#### `public.tags`
Predefined categories for tagging entries.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `name` | TEXT | Tag name (unique, 1-50 chars) |
| `category` | TEXT | Category: activity, event, emotion |
| `icon` | TEXT | Icon identifier |
| `created_at` | TIMESTAMP | Creation timestamp |

**Initial Tags** (from v1Spez.md):
- **Activity**: Nature & Hiking, Lake / Beach, City & Sightseeing, Food & Restaurant, Home & Everyday Life, Adventure / Sports, Nightlife, Roadtrip, Romantic Moments
- **Event**: Anniversary, Birthday, Holiday / Celebration, Travel, Surprise / Gift
- **Emotion**: Happy, Relaxed, Proud, In Love, Silly / Fun

**RLS**: Read-only for all authenticated users.

---

#### `public.entry_tags`
Many-to-many relationship between entries and tags.

| Column | Type | Description |
|--------|------|-------------|
| `entry_id` | UUID | Foreign key to entries |
| `tag_id` | UUID | Foreign key to tags |
| `created_at` | TIMESTAMP | Creation timestamp |

**Primary Key**: (`entry_id`, `tag_id`)

**RLS**: Users can only manage tags for their own entries.

---

### Storage Buckets

#### `photos`
Stores original uploaded photos.
- Path structure: `{user_id}/{photo_id}.{ext}`
- Private (not publicly accessible)

#### `thumbnails`
Stores generated thumbnails.
- Path structure: `{user_id}/{photo_id}_thumb.{ext}`
- Private (not publicly accessible)

**Storage RLS**: Users can only access files in their own user_id folder.

---

## Helper Views

### `entries_with_tags`
Entries with their associated tags (denormalized).

### `entries_with_photos_and_tags`
Complete entry view with photos and tags - used by frontend for efficient data loading.

### `logs_with_entry_count`
Logs with entry count and latest event date.

---

## Helper Functions

### `get_log_entries(log_uuid UUID)`
Get all entries for a specific log with full data (photos, tags).

```sql
SELECT * FROM get_log_entries('123e4567-e89b-12d3-a456-426614174000');
```

### `get_unprocessed_entries()`
Get entries that need background processing (used by worker functions).

```sql
SELECT * FROM get_unprocessed_entries();
```

### `mark_entry_processed(entry_uuid UUID)`
Mark an entry as processed by workers.

```sql
SELECT mark_entry_processed('123e4567-e89b-12d3-a456-426614174000');
```

### `get_tags_by_category()`
Get tags grouped by category (activity, event, emotion).

```sql
SELECT get_tags_by_category();
```

### `get_entry_tag_names(entry_uuid UUID)`
Get array of tag names for an entry (used by Smart Pages engine).

```sql
SELECT get_entry_tag_names('123e4567-e89b-12d3-a456-426614174000');
```

### `search_entries(...)`
Search entries by text, tags, or date range.

```sql
SELECT * FROM search_entries(
    log_uuid := '123e4567-e89b-12d3-a456-426614174000',
    search_text := 'beach',
    tag_ids := ARRAY['tag-uuid-1', 'tag-uuid-2']::UUID[],
    start_date := '2024-01-01'::TIMESTAMP,
    end_date := '2024-12-31'::TIMESTAMP
);
```

---

## Migrations

### Applying Migrations

Using Supabase CLI:

```bash
cd backend
supabase db push
```

### Creating New Migrations

```bash
supabase migration new <migration_name>
```

### Migration Files

1. **001_initial_schema.sql** - Core tables, RLS policies, seed data
2. **002_helper_views_and_functions.sql** - Utility views and functions

---

## Row Level Security (RLS)

All tables have RLS enabled to ensure data isolation:

- **Users can only access their own data**
- Policies enforce ownership through `user_id` chain: `logs.user_id` → `entries.log_id` → `photos.entry_id`
- Storage policies enforce folder-based access: `{user_id}/*`

### Testing RLS

```sql
-- Set auth context for testing
SET request.jwt.claims.sub = 'test-user-uuid';

-- Now queries will respect RLS policies
SELECT * FROM public.logs; -- Only returns logs owned by test-user-uuid
```

---

## Indexes

Performance indexes are created for:
- Foreign key relationships
- Date-based queries (`event_date`, `created_at`)
- User lookups (`user_id`)
- Processing status (`is_processed`)

---

## Data Flow

### Creating a New Entry

1. **User uploads photos** → Stored in `storage.objects` (photos bucket)
2. **Create entry record** → `public.entries`
3. **Create photo records** → `public.photos` with `storage_path`
4. **Assign tags** → `public.entry_tags`
5. **Trigger worker** → Background processing starts
6. **Worker updates**:
   - Extract EXIF → Update `photos.exif_data`
   - Generate thumbnail → Update `photos.thumbnail_path`
   - Compute colors → Update `photos.dominant_colors`
   - Reverse geocode → Update `entries.location_*`
   - Compute Smart Page → Update `entries.page_layout_type`, `color_theme`, `sprinkles`
7. **Mark processed** → `entries.is_processed = TRUE`

---

## Best Practices

1. **Always use RLS-aware queries** - Test with different user contexts
2. **Use views for complex queries** - Prefer `entries_with_photos_and_tags` over manual joins
3. **Leverage helper functions** - Reduces code duplication
4. **Index wisely** - Monitor query performance and add indexes as needed
5. **Respect data limits**:
   - Log names: 1-100 chars
   - Highlight text: 0-500 chars
   - Tag names: 1-50 chars

---

## Future Enhancements (V2+)

- Shared logs (multi-user collaboration)
- Materialized views for performance
- Full-text search (pg_trgm, tsvector)
- Geographic queries (PostGIS extension)
- AI-assisted tagging metadata tables

---

## Troubleshooting

### RLS Not Working
- Ensure `auth.uid()` is set correctly
- Check that RLS is enabled: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`
- Verify policies with `\dp <table>` in psql

### Storage Access Denied
- Verify storage bucket policies are created
- Check folder structure matches `{user_id}/...`
- Ensure authenticated user context

### Migration Errors
- Run migrations in order (001, 002, ...)
- Check Supabase dashboard for error details
- Verify extensions are enabled (uuid-ossp, pgcrypto)

---

## Contact

For questions about the database schema, see:
- [docs/architecture.md](../../docs/architecture.md)
- [docs/v1Spez.md](../../docs/v1Spez.md)
