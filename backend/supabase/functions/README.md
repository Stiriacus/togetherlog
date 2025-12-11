# TogetherLog - Supabase Edge Functions

This directory contains all Supabase Edge Functions (TypeScript/Deno) for TogetherLog.

## Directory Structure

```
functions/
├── _shared/              # Shared utilities (CORS, auth, validation)
├── api-logs/             # REST API for Logs CRUD
├── api-entries/          # REST API for Entries CRUD
├── reverse-geocode/      # Worker: GPS → location names
├── process-photo/        # Worker: Photo processing and EXIF
├── compute-colors/       # Worker: Dominant color extraction
└── compute-smart-page/   # Worker: Smart Page layout & theme computation
```

## Function Descriptions

### REST API Functions

#### `api-logs`
**Purpose**: CRUD operations for logs (memory books)

**Routes**:
- `GET /api-logs` - List all logs for current user
- `GET /api-logs/:id` - Get single log
- `POST /api-logs` - Create new log
- `PATCH /api-logs/:id` - Update log
- `DELETE /api-logs/:id` - Delete log

**Auth**: Requires Supabase Auth token in Authorization header

---

#### `api-entries`
**Purpose**: CRUD operations for entries with photos, tags, and location

**Routes**:
- `GET /api-entries/tags` - List all available tags
- `GET /api-entries/logs/:logId/entries` - List entries for a log
- `GET /api-entries/:id` - Get single entry with photos and tags
- `POST /api-entries/logs/:logId/entries` - Create new entry
- `PATCH /api-entries/:id` - Update entry
- `DELETE /api-entries/:id` - Delete entry

**Auth**: Requires Supabase Auth token in Authorization header

---

### Worker Functions

#### `reverse-geocode`
**Purpose**: Convert GPS coordinates to human-readable location names

**Input**:
```json
{
  "entry_id": "uuid",
  "lat": 52.5200,
  "lng": 13.4050
}
```

**Process**:
- Calls OpenStreetMap Nominatim API
- Respects rate limit (1 req/sec)
- Parses address into readable format
- Updates entry's `location_display_name`

**Output**: Updated entry in database

---

#### `process-photo`
**Purpose**: Process uploaded photos (EXIF extraction, URL generation)

**Input**:
```json
{
  "photo_id": "uuid",
  "storage_path": "photos/..."
}
```

**Process**:
- Generates public URL for photo
- V1: Placeholder for EXIF extraction (requires image library)
- V1: Placeholder for thumbnail generation (requires image library)
- Updates photo metadata

**Output**: Updated photo record

**V1 Limitations**: Full EXIF and thumbnail generation require image processing libraries. See function comments for upgrade paths.

---

#### `compute-colors`
**Purpose**: Extract dominant colors from photos

**Input**:
```json
{
  "photo_id": "uuid",
  "url": "https://..."
}
```

**Process**:
- V1: Uses placeholder colors
- V2: Will analyze image pixels for dominant colors

**Output**: Updated photo with `dominant_colors` array

**V1 Limitations**: Requires image processing library for real color extraction.

---

#### `compute-smart-page`
**Purpose**: Compute Smart Page layout, color theme, and sprinkles

**Input**:
```json
{
  "entry_id": "uuid"
}
```

**Process**:
- Fetches entry with photos and tags
- **RULE 1**: Compute layout type based on photo count
  - 0-1 photos → `single_full`
  - 2-4 photos → `grid_2x2`
  - 5+ photos → `grid_3x2`
- **RULE 2**: Compute color theme (Emotion-Color-Engine V1)
  - Tag-based priority mapping
  - Fallback to dominant photo color
  - Default to neutral
- **RULE 3**: Compute sprinkles (decorative icons)
  - Tag-to-icon mapping
  - Max 3 sprinkles
- Updates entry with computed fields

**Output**: Updated entry with `page_layout_type`, `color_theme`, `sprinkles`, `is_processed=true`

---

## Shared Utilities (`_shared/`)

### `cors.ts`
- `corsHeaders` - Standard CORS headers
- `successResponse(data, status)` - Success response helper
- `errorResponse(message, status)` - Error response helper

### `auth.ts`
- `getAuthContext(req)` - Extract and validate Supabase Auth user from request
- Returns: `{ user: { id, email }, supabase: SupabaseClient }`

### `validation.ts`
- `validateRequired(value, field)` - Check required field
- `validateString(value, field, minLen, maxLen)` - Validate string length
- `validateEnum(value, field, allowedValues)` - Validate enum value
- `validateUUID(value, field)` - Validate UUID format

---

## Deployment

### Prerequisites

1. **Install Supabase CLI**:
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase**:
   ```bash
   supabase login
   ```

3. **Link to your project**:
   ```bash
   supabase link --project-ref your-project-ref
   ```

### Deploy All Functions

From the project root:

```bash
supabase functions deploy
```

This will deploy all functions in `backend/supabase/functions/`.

### Deploy Individual Function

```bash
supabase functions deploy api-logs
supabase functions deploy api-entries
supabase functions deploy reverse-geocode
supabase functions deploy process-photo
supabase functions deploy compute-colors
supabase functions deploy compute-smart-page
```

### Set Environment Variables

Functions need access to Supabase credentials:

```bash
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_ANON_KEY=your-anon-key
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### View Function Logs

```bash
supabase functions logs api-logs
supabase functions logs compute-smart-page
```

---

## Testing Functions Locally

### Serve Function Locally

```bash
supabase functions serve api-logs --env-file backend/.env
```

### Test with curl

**Test Logs API**:
```bash
curl -X POST http://localhost:54321/functions/v1/api-logs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Our Memories", "type": "Couple"}'
```

**Test Worker**:
```bash
curl -X POST http://localhost:54321/functions/v1/compute-smart-page \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"entry_id": "uuid-here"}'
```

---

## Architecture Notes

- **Backend Authoritative**: All business logic runs on the backend
- **TypeScript/Deno**: All functions use TypeScript with Deno runtime
- **RLS Enforcement**: API functions enforce Row Level Security via Supabase Auth
- **Worker Pattern**: Workers are triggered after data changes (via API calls or database triggers)
- **Shared Code**: Common utilities in `_shared/` to avoid duplication

---

## Function URLs

After deployment, functions are accessible at:

```
https://your-project.supabase.co/functions/v1/api-logs
https://your-project.supabase.co/functions/v1/api-entries
https://your-project.supabase.co/functions/v1/reverse-geocode
https://your-project.supabase.co/functions/v1/process-photo
https://your-project.supabase.co/functions/v1/compute-colors
https://your-project.supabase.co/functions/v1/compute-smart-page
```

---

## Development Workflow

1. Make changes to function code
2. Test locally with `supabase functions serve`
3. Deploy to production with `supabase functions deploy function-name`
4. Monitor logs with `supabase functions logs function-name`
5. Iterate

---

## Troubleshooting

### Function not found
- Ensure function directory has `index.ts` file
- Check that you're in the correct directory when deploying
- Verify project is linked: `supabase link --project-ref your-ref`

### Import errors
- All imports must use Deno-compatible URLs (https://deno.land/...)
- Shared utilities: `import { ... } from '../_shared/file.ts'`
- Always include `.ts` extension in imports

### CORS errors
- All API functions include `corsHeaders` in responses
- OPTIONS method returns CORS headers for preflight requests

### Auth errors
- Verify Authorization header is included: `Bearer YOUR_TOKEN`
- Check token is valid: `supabase auth verify`
- Ensure RLS policies allow the operation

---

## Next Steps

- Implement missing EXIF extraction (requires image library or external service)
- Implement thumbnail generation (requires image library or external service)
- Implement real color extraction (requires image library)
- Add database triggers to auto-invoke workers
- Set up monitoring and alerting
- Add rate limiting for public endpoints
