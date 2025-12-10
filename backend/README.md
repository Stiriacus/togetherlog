# TogetherLog Backend

Supabase-based backend for TogetherLog, using PostgreSQL, Auth, Storage, and Edge Functions.

## Tech Stack

- **Supabase PostgreSQL** - Main database
- **Supabase Auth** - Email/password + Google OAuth
- **Supabase Storage** - Photo and thumbnail storage (EU region)
- **Supabase Edge Functions** - TypeScript/Deno REST API and workers

## Project Structure

```
backend/
├── edge-functions/
│   ├── api/           # REST API endpoints
│   │   ├── logs/      # Log CRUD operations
│   │   └── entries/   # Entry CRUD operations
│   └── workers/       # Async background workers
│       ├── process-photo/      # EXIF extraction, thumbnails
│       ├── compute-colors/     # Dominant color analysis
│       ├── reverse-geocode/    # GPS to location name
│       └── compute-smart-page/ # Smart Page engine
└── sql/
    └── migrations/    # Database schema migrations
```

## Core Responsibilities

### REST API (`/edge-functions/api`)
- User authentication
- Log management (CRUD)
- Entry management (CRUD)
- Photo upload handling

### Workers (`/edge-functions/workers`)
- **process-photo**: Extract EXIF metadata, generate thumbnails
- **compute-colors**: Extract dominant colors from images
- **reverse-geocode**: Convert GPS coordinates to human-readable locations (OpenStreetMap/Nominatim)
- **compute-smart-page**: Run deterministic Smart Page engine
  - Select page layout type
  - Choose color theme (Emotion-Color-Engine V1)
  - Generate sprinkles placeholders

### Database (`/sql/migrations`)
- Schema definitions
- Row Level Security (RLS) policies
- Indexes and constraints

## Development

### Prerequisites

- Supabase CLI
- Deno runtime (for local testing)

### Setup

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Link to your Supabase project:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```

3. Run migrations:
   ```bash
   supabase db push
   ```

4. Deploy Edge Functions:
   ```bash
   supabase functions deploy
   ```

### Local Development

```bash
# Start Supabase locally
supabase start

# Serve a specific function
supabase functions serve <function-name>
```

## Architecture Principles

1. **Backend-authoritative**: All Smart Page logic runs on the backend
2. **Deterministic rules**: No AI in V1, only rule-based systems
3. **Async processing**: Heavy operations (EXIF, thumbnails) run as background workers
4. **GDPR compliance**: Data stored in EU region
5. **RLS everywhere**: All database access controlled by Row Level Security

## Smart Pages Engine (V1)

The Smart Page engine is fully deterministic and rule-based:

**Inputs:**
- Number of photos
- Tags
- Highlight text length
- Location availability

**Outputs:**
- `page_layout_type` (e.g., single_full, grid_2x2, polaroid_grid)
- `color_theme` (based on Emotion-Color-Engine V1)
- `sprinkles[]` (decorative icons, optional)

**Rules:**
- 1 photo → hero/single layout
- 2-4 photos → grid/collage
- Tags determine color themes (e.g., Romantic → warm reds, Nature → greens)

## Deployment

### Production
```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy <function-name>
```

### Migrations
```bash
# Create new migration
supabase migration new <migration-name>

# Apply migrations
supabase db push
```

## License

MIT
