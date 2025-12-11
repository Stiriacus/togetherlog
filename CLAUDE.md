# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TogetherLog** is a Flutter-based flipbook application for preserving shared memories, backed by Supabase. The core innovation is the **Smart Pages Engine** - a backend-authoritative system that automatically generates beautiful page layouts based on photos, tags, and emotions.

- **Frontend**: Flutter (Web + Android)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Current Status**: 8/12 milestones completed (66.7%)
  - Backend fully operational
  - Auth flow complete
  - Ready for Logs/Entries/Flipbook UI implementation

## Essential Reading

Before working on this codebase, read these files **in order**:

1. **`docs/v1Spez.md`** - Complete product requirements for V1 MVP
2. **`docs/architecture.md`** - System architecture and technical decisions
3. **`docs/CONTEXT.md`** - Comprehensive project context for AI assistants
4. **`docs/MILESTONES.md`** - Development roadmap with detailed implementation steps

## Critical Architecture Principles

These principles are **non-negotiable** and must be followed at all times:

### 1. Backend Authoritative
- **All business logic runs on the backend** (Supabase Edge Functions)
- Smart Page computation (layout types, color themes, sprinkles) is **server-side only**
- Image processing, EXIF extraction, and geocoding happen on backend
- Flutter app **NEVER** computes layouts, themes, or performs image analysis

### 2. Frontend Lean
- Flutter app only renders UI and handles user input
- No Smart Page logic in Flutter code - client receives pre-computed data
- All API calls go through Supabase Edge Functions (REST endpoints)

### 3. Clean Architecture
```
app/lib/
├── core/           # Routing, theme, utilities
├── data/           # API clients, models, repositories
└── features/       # Feature-based modules
    └── [feature]/
        ├── data/       # Repository layer
        ├── providers/  # Riverpod state management
        └── widgets/    # UI components
```

### 4. No Feature Drift
- Only implement features specified in `docs/v1Spez.md`
- Do NOT add "helpful" features, abstractions, or optimizations
- Keep implementations simple and focused

### 5. Backtest Everything
Before any commit, verify:
- Requirements compliance against `docs/v1Spez.md`
- Architecture compliance against `docs/architecture.md`
- All code paths tested
- Backend authoritative principle maintained

## Common Development Commands

### Flutter App

```bash
# Navigate to app directory
cd app

# Get dependencies
flutter pub get

# Run on web (development)
flutter run -d chrome

# Run on Android device
flutter devices  # List available devices
flutter run -d <device-id>

# Build for production
flutter build web --release
flutter build apk --release
flutter build appbundle --release

# Clean build cache
flutter clean && flutter pub get

# Run code generation (Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

### Backend (Supabase)

```bash
# Navigate to project root
cd /home/xeath/Documents/Code/Flutter/togetherlog

# Apply database migrations
cd backend
supabase db push

# Deploy all Edge Functions
supabase functions deploy

# Deploy specific function
supabase functions deploy <function-name>

# Serve function locally for testing
supabase functions serve <function-name>

# Create new migration
supabase migration new <migration-name>

# Start local Supabase instance
supabase start

# Stop local Supabase
supabase stop
```

### Git Workflow

```bash
# All development happens on this branch:
git checkout claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3

# Commit format for milestones:
git commit -m "feat(milestone-X): brief description, backtested

Detailed description:
- What was implemented
- Architecture compliance
- Backtest results

Files:
- file1.dart (XX lines)
- file2.dart (XX lines)"

# Push to branch
git push origin claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3
```

## Code Architecture & Structure

### Backend Structure

```
backend/supabase/
├── functions/                  # Edge Functions (TypeScript/Deno)
│   ├── _shared/                # Shared utilities
│   │   ├── cors.ts             # CORS headers
│   │   ├── auth.ts             # Auth helpers
│   │   └── validation.ts       # Request validation
│   ├── api-logs/               # Logs CRUD REST API
│   ├── api-entries/            # Entries CRUD REST API
│   ├── reverse-geocode/        # GPS → location worker
│   ├── process-photo/          # EXIF extraction worker
│   ├── compute-colors/         # Color analysis worker
│   └── compute-smart-page/     # Smart Pages Engine (241 lines)
└── migrations/
    ├── 001_initial_schema.sql          # Core tables + RLS
    └── 002_helper_views_and_functions.sql  # Optimized views
```

### Frontend Structure

```
app/lib/
├── core/
│   ├── routing/
│   │   └── router.dart         # go_router with auth guards
│   └── theme/
│       └── smart_page_theme.dart  # Color theme mappings (to be created)
├── data/
│   ├── api/
│   │   └── supabase_client.dart    # Supabase initialization
│   └── models/
│       ├── user.dart               # User model
│       ├── log.dart                # Log model (to be expanded)
│       ├── entry.dart              # Entry model (to be created)
│       ├── photo.dart              # Photo model (to be created)
│       └── tag.dart                # Tag model (to be created)
└── features/
    ├── auth/                   #   COMPLETED (MILESTONE 8)
    │   ├── data/
    │   │   └── auth_repository.dart
    │   ├── providers/
    │   │   └── auth_providers.dart
    │   └── widgets/
    │       ├── login_form.dart
    │       └── signup_form.dart
    ├── logs/                   #   MILESTONE 9 (Next)
    │   └── logs_screen.dart    # Placeholder, needs implementation
    ├── entries/                #   MILESTONE 10
    │   └── entry_create_screen.dart  # Placeholder
    └── flipbook/               #   MILESTONE 11
        └── flipbook_viewer.dart      # Placeholder
```

## Database Schema Overview

### Core Tables
- **`users`** - Managed by Supabase Auth
- **`logs`** - User's memory books (id, user_id, name, type)
- **`entries`** - Individual memories (id, log_id, event_date, highlight_text, location, Smart Page fields)
- **`photos`** - Entry photos (id, entry_id, url, thumbnail_url, dominant_colors, metadata)
- **`tags`** - Predefined tags (19 seed tags: Activity, Event, Emotion categories)
- **`entry_tags`** - Many-to-many relationship

### Smart Page Fields (on `entries` table)
- `page_layout_type` - single_full | grid_2x2 | grid_3x2
- `color_theme` - warm_red | earth_green | ocean_blue | deep_purple | warm_earth | soft_rose | neutral
- `sprinkles` - JSONB array of decorative icon identifiers
- `is_processed` - boolean flag indicating Smart Page computation complete

### Optimized Views
- **`entries_with_photos_and_tags`** - Subquery aggregation for performance (avoids N+1 queries)

### Row Level Security (RLS)
All tables have RLS policies enforcing:
- Users can only access their own logs/entries/photos
- Enforced at PostgreSQL level (defense in depth)

## Smart Pages Engine

**Location**: `backend/supabase/functions/compute-smart-page/index.ts` (241 lines)

The Smart Pages Engine is the heart of TogetherLog. It runs **entirely on the backend** and applies three deterministic rule engines:

### RULE 1: Layout Type Selection
Based on photo count:
- 0-1 photos → `single_full` (hero layout)
- 2-4 photos → `grid_2x2` (grid layout)
- 5-6 photos → `grid_3x2` (max 6 photos displayed)

### RULE 2: Color Theme Selection (Emotion-Color-Engine V1)
Tag-based priority system:
1. Romantic/In Love/Anniversary → `warm_red`
2. Nature & Hiking/Adventure → `earth_green`
3. Lake/Beach → `ocean_blue`
4. Nightlife → `deep_purple`
5. Food/Home → `warm_earth`
6. Travel → `soft_rose`
7. Fallback: Dominant photo color
8. Default: `neutral`

### RULE 3: Sprinkles Selection
Tag-to-icon mapping (max 3 decorative icons):
- Romantic → heart
- Nature → mountain
- Beach → beach icon
- Travel → airplane
- Food → utensils
- Birthday → balloon
- Happy → star

**Flutter's Job**: Render the pre-computed layout using the provided theme and sprinkles. **No computation.**

## API Endpoints

All endpoints deployed at: `https://ikspskghylahtexiqepl.supabase.co/functions/v1/`

### Logs API (`/api-logs`)
- `GET /api-logs` - List all logs for current user
- `GET /api-logs/:id` - Get specific log
- `POST /api-logs` - Create new log (body: name, type)
- `PATCH /api-logs/:id` - Update log
- `DELETE /api-logs/:id` - Delete log

### Entries API (`/api-entries`)
- `GET /api-entries/tags` - List all predefined tags
- `GET /api-entries/logs/:logId/entries` - List entries for a log
- `GET /api-entries/entries/:id` - Get entry with photos and tags
- `POST /api-entries/logs/:logId/entries` - Create entry
- `PATCH /api-entries/entries/:id` - Update entry
- `DELETE /api-entries/entries/:id` - Delete entry

### Workers (Background Functions)
- `/reverse-geocode` - GPS coordinates → location name (Nominatim)
- `/process-photo` - EXIF extraction and thumbnail generation
- `/compute-colors` - Dominant color analysis
- `/compute-smart-page` - Smart Page engine computation

## Development Workflow

### Standard Workflow for Every Milestone

```
READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → PUSH → NEXT
```

1. **READ**: Read requirements in `docs/v1Spez.md` and `docs/architecture.md`
2. **ANALYZE**: Check existing code and verify previous milestones
3. **PLAN**: Create detailed implementation plan with file list
4. **CODE**: Implement following clean architecture principles
5. **BACKTEST**: Verify against requirements, test functionality, check architecture compliance
6. **FIX**: Address any issues found
7. **COMMIT**: Use format `feat(milestone-X): description, backtested`
8. **PUSH**: Push to branch `claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3`
9. **NEXT**: Update `docs/MILESTONES.md` and move to next milestone

### Testing Strategy

Manual testing for V1:
- Test auth flow: signup → login → logout
- Test CRUD operations for logs and entries
- Verify RLS policies (User A cannot access User B's data)
- Test photo upload to Supabase Storage
- Verify Smart Page computation triggers
- Test flipbook page-turn animation smoothness

## Technology Stack

### Frontend
- **Flutter 3.32.5** - UI framework (Web + Android)
- **Riverpod 2.4.0** - State management (`flutter_riverpod`, `riverpod_annotation`)
- **go_router 13.0.0** - Declarative routing with auth guards
- **dio 5.4.0** - HTTP client for REST API calls
- **supabase_flutter 2.0.0** - Supabase client SDK
- **image_picker 1.0.7** - Photo selection from device
- **page_flip 0.2.0** - 3D page-turn animation

### Backend
- **Supabase PostgreSQL** - Main database with Row Level Security
- **Supabase Auth** - Email/password + Google OAuth
- **Supabase Storage** - Photo and thumbnail storage (EU region)
- **Supabase Edge Functions** - TypeScript/Deno serverless functions
- **OpenStreetMap/Nominatim** - Reverse geocoding

## Current Project Status

### Completed (8/12 milestones)
-   MILESTONE 0-2: Project foundation, Flutter init, backend structure
-   MILESTONE 3: Database schema with RLS policies
-   MILESTONE 4: Logs REST API
-   MILESTONE 5: Entries REST API
-   MILESTONE 6: Worker functions (geocoding, photo processing, color extraction)
-   MILESTONE 7: Smart Pages Engine (core feature)
-   MILESTONE 8: Flutter Auth UI (login, signup, auth guards)

### Next Up
-   **MILESTONE 9: Flutter Logs Feature** ← **YOU ARE HERE**
  - Implement logs list, create, edit, delete UI
  - Connect to `/api-logs` endpoints
  - Use Riverpod for state management
  - See `docs/MILESTONES.md` for detailed steps

### Remaining
-   MILESTONE 10: Flutter Entries Feature (photo upload, tags, location)
-   MILESTONE 11: Flipbook Viewer (3D page-turn animation, Smart Page rendering)
-   MILESTONE 12: Integration testing and validation

## Common Pitfalls to Avoid

### 1. Smart Page Logic in Flutter
-   **WRONG**: Computing layout types or color themes in Flutter
-   **CORRECT**: Fetching pre-computed data from backend and rendering it

### 2. Feature Drift
-   **WRONG**: Adding "helpful" features not in `v1Spez.md`
-   **CORRECT**: Only implementing specified features

### 3. Over-Engineering
-   **WRONG**: Creating abstractions "for future flexibility"
-   **CORRECT**: Simple, direct implementations

### 4. Ignoring RLS
-   **WRONG**: Assuming backend validates ownership via app logic
-   **CORRECT**: RLS policies enforce user ownership at database level

### 5. Forgetting to Backtest
-   **WRONG**: Committing without verification against requirements
-   **CORRECT**: Always verify against `v1Spez.md` before committing

## Environment Configuration

### Required Environment Variables

**Flutter App** (use `--dart-define` or hardcode in `main.dart` for V1):
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

**Supabase Edge Functions** (configured in Supabase dashboard secrets):
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY` - For backend worker functions

**Note**: Never commit credentials to git. Use environment variables or Supabase secrets.

## Deployed Supabase Project

- **Project ID**: `ikspskghylahtexiqepl`
- **Region**: EU (GDPR compliant)
- **Status**: All Edge Functions deployed and operational

## Key Files to Reference

### Documentation
- `README.md` - Project overview
- `docs/CONTEXT.md` - Comprehensive context for AI assistants (read this!)
- `docs/v1Spez.md` - Product specification (source of truth for features)
- `docs/architecture.md` - Technical architecture
- `docs/MILESTONES.md` - Development roadmap with detailed steps
- `docs/SETUP.md` - Setup and development guide

### Backend
- `backend/README.md` - Backend overview
- `backend/supabase/functions/README.md` - Edge Functions documentation
- `backend/supabase/README.md` - Database schema documentation

### Frontend
- `app/README.md` - Flutter app status and setup
- `app/pubspec.yaml` - Dependencies list
- `app/lib/main.dart` - App entry point with Supabase initialization
- `app/lib/core/routing/router.dart` - Routing configuration

## Quick Reference for Next Milestone (9)

When implementing MILESTONE 9 (Flutter Logs Feature):

1. Create `app/lib/data/api/logs_api_client.dart` - dio HTTP client calling `/api-logs`
2. Expand `app/lib/data/models/log.dart` - add fromJson/toJson
3. Create `app/lib/features/logs/data/logs_repository.dart` - repository pattern
4. Create `app/lib/features/logs/providers/logs_providers.dart` - Riverpod providers
5. Create UI widgets in `app/lib/features/logs/widgets/`:
   - `log_card.dart` - Display single log
   - `log_list.dart` - Display logs list
   - `create_log_dialog.dart` - Create log dialog
   - `edit_log_dialog.dart` - Edit log dialog
6. Update `app/lib/features/logs/logs_screen.dart` - Complete implementation
7. Add route `/logs/:logId/entries` in router for navigation

See `docs/MILESTONES.md` section "MILESTONE 9" for complete implementation steps and backtest checklist.

## Performance Targets

- API response times < 1 second
- Flipbook smooth page turns (60fps target)
- Photo uploads < 5 seconds
- Web build size < 10 MB

## License

MIT License - See `LICENSE` file
