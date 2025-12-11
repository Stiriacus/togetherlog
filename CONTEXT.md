# TogetherLog - Project Context for AI Assistants

This file provides a comprehensive overview of the TogetherLog project for AI assistants (Claude Code, etc.) to quickly understand the codebase, architecture, and development status.

---

## 🎯 Project Overview

**TogetherLog** is a beautiful, interactive flipbook application for preserving shared memories. Users can create logs (memory books), add entries with photos and tags, and view them in a flipbook format with automatic page design.

**Key Innovation**: **Smart Pages Engine** - Automatically generates visually consistent memory pages based on photos, tags, and emotions, so users don't need to manually design layouts.

**Target Platforms**: Flutter (Web + Android)
**Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
**License**: MIT (Open Source)

---

## 📚 Essential Documentation

Before working on this project, read these files in order:

### 1. Product Specification
**File**: [`docs/v1Spez.md`](docs/v1Spez.md)
- Complete product requirements for V1
- User workflows and features
- Data models (Logs, Entries, Photos, Tags)
- Smart Pages Engine specification
- Emotion-Color-Engine V1 rules
- UI/UX requirements

### 2. Technical Architecture
**File**: [`docs/architecture.md`](docs/architecture.md)
- System architecture and components
- Data flow diagrams
- Frontend/backend separation
- Deployment strategy
- Backend authoritative principles

### 3. Development Roadmap
**File**: [`MILESTONES.md`](MILESTONES.md)
- Detailed milestone tracking (0-12)
- Implementation steps for each milestone
- Backtest requirements
- Progress tracker (currently 8/12 completed)

### 4. Backend Documentation
**File**: [`backend/README.md`](backend/README.md)
- Backend structure and responsibilities
- Supabase setup and deployment
- Database migrations guide

**File**: [`backend/supabase/README.md`](backend/supabase/README.md)
- Database schema documentation
- RLS policies explained
- Helper views and functions

**File**: [`backend/supabase/functions/README.md`](backend/supabase/functions/README.md)
- All Edge Functions documented
- REST API routes and examples
- Worker functions descriptions
- Deployment instructions

### 5. Flutter App Documentation
**File**: [`app/README.md`](app/README.md)
- Flutter setup and configuration
- Supabase credentials setup
- Development status
- Build instructions

### 6. Future Features (Out of Scope for V1)
**File**: [`docs/v2optional.md`](docs/v2optional.md)
- Features planned for V2+
- **DO NOT implement these in V1** - will cause feature drift

---

## 🏗️ Architecture Principles (CRITICAL)

These principles MUST be followed at all times:

### 1. Backend Authoritative
- **All business logic runs on the backend** (Supabase Edge Functions)
- Smart Page computation happens server-side only
- Image processing and EXIF extraction on backend
- Frontend NEVER computes layouts, themes, or sprinkles

### 2. Frontend Lean
- Flutter app only renders UI and handles user input
- No Smart Page logic in Flutter code
- Client receives pre-computed data from backend and displays it
- All API calls go through Supabase Edge Functions

### 3. Clean Architecture
```
app/lib/
├── core/           # Routing, theme, utilities
├── data/           # API clients, models, repositories
└── features/       # Feature-based modules (auth, logs, entries, flipbook)
    └── feature/
        ├── data/       # Repository
        ├── providers/  # Riverpod state management
        └── widgets/    # UI components
```

### 4. No Feature Drift
- Only implement features specified in `docs/v1Spez.md`
- Do NOT add extra features, optimizations, or abstractions
- Keep it simple and focused
- Avoid over-engineering

### 5. Backtest Everything
Before committing any milestone:
- Verify against requirements in `docs/v1Spez.md`
- Check architecture compliance against `docs/architecture.md`
- Test all code paths
- Verify file sizes and line counts

---

## 📁 Repository Structure

```
TogetherLog/
├── docs/                           # All documentation
│   ├── v1Spez.md                   # Product specification (READ FIRST)
│   ├── architecture.md             # Technical architecture
│   └── v2optional.md               # Future features (DO NOT IMPLEMENT)
│
├── backend/                        # Supabase backend
│   └── supabase/
│       ├── migrations/             # PostgreSQL schema migrations
│       │   ├── 001_initial_schema.sql
│       │   └── 002_helper_views_and_functions.sql
│       ├── functions/              # Edge Functions (TypeScript/Deno)
│       │   ├── _shared/            # Shared utilities (CORS, auth, validation)
│       │   ├── api-logs/           # REST API: Logs CRUD
│       │   ├── api-entries/        # REST API: Entries CRUD
│       │   ├── reverse-geocode/    # Worker: GPS → location names
│       │   ├── process-photo/      # Worker: Photo processing
│       │   ├── compute-colors/     # Worker: Color extraction
│       │   └── compute-smart-page/ # Worker: Smart Page engine ⭐
│       └── config.toml             # Supabase configuration
│
├── app/                            # Flutter application
│   └── lib/
│       ├── core/
│       │   └── routing/            # go_router configuration
│       ├── data/
│       │   ├── api/                # Supabase client, API clients
│       │   └── models/             # Data models (User, Log, Entry, Photo, Tag)
│       └── features/
│           ├── auth/               # ✅ Authentication (COMPLETED)
│           ├── logs/               # ⏳ Logs list/CRUD (MILESTONE 9)
│           ├── entries/            # ⏳ Entries CRUD (MILESTONE 10)
│           └── flipbook/           # ⏳ Flipbook viewer (MILESTONE 11)
│
├── MILESTONES.md                   # Development roadmap and tracking
├── CONTEXT.md                      # This file
└── README.md                       # Project overview
```

---

## 🎨 Smart Pages Engine (Core Feature)

The Smart Pages Engine is the heart of TogetherLog. It automatically designs beautiful memory pages.

### How It Works

**Location**: `backend/supabase/functions/compute-smart-page/index.ts` (241 lines)

**Process**:
1. Entry is created with photos and tags
2. Backend worker function `compute-smart-page` is triggered
3. Three rule engines run:

#### RULE 1: Layout Type Selection
Based on photo count:
- 0-1 photos → `single_full` (hero layout)
- 2-4 photos → `grid_2x2` (grid layout)
- 5+ photos → `grid_3x2` (max 6 photos displayed)

#### RULE 2: Color Theme Selection (Emotion-Color-Engine V1)
Based on tags with priority order:
- Romantic/In Love/Anniversary → `warm_red`
- Nature & Hiking/Adventure → `earth_green`
- Lake/Beach → `ocean_blue`
- Nightlife → `deep_purple`
- Food/Home → `warm_earth`
- Travel → `soft_rose`
- Fallback: Dominant photo color
- Default: `neutral`

#### RULE 3: Sprinkles Selection
Based on tags (max 3 decorative icons):
- Romantic → heart
- Nature → mountain
- Beach → beach icon
- Travel → airplane
- Food → utensils
- Birthday → balloon
- Happy → star
- etc.

**Output**: Entry updated with `page_layout_type`, `color_theme`, `sprinkles[]`, `is_processed=true`

**Flutter's Job**: Just render the provided layout with the provided theme. No computation.

---

## ✅ Completed Work (Milestones 0-8)

### Backend (100% Complete for V1)
- ✅ PostgreSQL schema with RLS policies
- ✅ Optimized database views (subquery aggregation)
- ✅ REST API for Logs CRUD (`api-logs/`)
- ✅ REST API for Entries CRUD (`api-entries/`)
- ✅ Worker: Reverse geocoding with Nominatim (`reverse-geocode/`)
- ✅ Worker: Photo processing (`process-photo/`)
- ✅ Worker: Color extraction (`compute-colors/`)
- ✅ Worker: Smart Pages Engine (`compute-smart-page/`) ⭐
- ✅ All Edge Functions deployed to Supabase

### Flutter Frontend (Auth Complete)
- ✅ App initialization and dependencies
- ✅ Supabase client integration
- ✅ Auth UI (login, signup with email/password)
- ✅ Riverpod state management for auth
- ✅ go_router with auth-based redirects
- ✅ Clean architecture foundation

### Current State
- **8/12 milestones completed (66.7%)**
- **Backend is production-ready**
- **Auth flow is fully functional**
- **Ready for MILESTONE 9 (Logs feature)**

---

## ⏳ Remaining Work (Milestones 9-12)

### MILESTONE 9: Flutter Logs Feature
**Status**: Not started
**Complexity**: Medium
**Estimated LOC**: ~400 lines

**Tasks**:
1. Create Logs API client (dio + Supabase Auth headers)
2. Create Logs repository
3. Create Logs providers (Riverpod)
4. Build Logs UI (list, create, edit, delete)
5. Navigation integration

**Files to Create/Modify**:
- `app/lib/data/api/logs_api_client.dart` (new)
- `app/lib/features/logs/data/logs_repository.dart` (new)
- `app/lib/features/logs/providers/logs_providers.dart` (new)
- `app/lib/features/logs/widgets/*.dart` (new)
- `app/lib/features/logs/logs_screen.dart` (update)

### MILESTONE 10: Flutter Entries Feature
**Status**: Not started
**Complexity**: High
**Estimated LOC**: ~800 lines

**Tasks**:
1. Create Entries API client + Storage API client
2. Create Entry, Photo, Tag models
3. Create Entries providers
4. Build photo upload flow (image_picker + Supabase Storage)
5. Build entry creation UI (photos, tags, location, text)
6. Build entry editing UI

**Key Challenge**: Photo upload to Supabase Storage

### MILESTONE 11: Flipbook Viewer
**Status**: Not started
**Complexity**: High
**Estimated LOC**: ~600 lines

**Tasks**:
1. Create Smart Page renderer (interprets backend layout data)
2. Create layout widgets (single_full, grid_2x2, grid_3x2)
3. Create theme builder (color theme mapping)
4. Implement 3D page-turn animation (page_flip package)
5. Gesture controls (swipe, click)

**Key Challenge**: Smooth page-turn animation on Web + Android

### MILESTONE 12: Integration Testing
**Status**: Not started
**Complexity**: Medium

**Tasks**:
1. End-to-end user flow testing
2. Backend worker verification
3. RLS policy testing
4. Performance testing
5. Cross-platform testing (Web + Android)
6. Bug fixes and final validation

---

## 🛠️ Development Workflow

### Standard Workflow for Every Milestone
```
READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → PUSH → NEXT
```

1. **READ**: Read `v1Spez.md`, `architecture.md`, and relevant READMEs
2. **ANALYZE**: Check existing code, verify previous milestones
3. **PLAN**: Create detailed implementation plan with file list
4. **CODE**: Implement following clean architecture principles
5. **BACKTEST**: Verify against requirements, test functionality
6. **FIX**: Address any issues found
7. **COMMIT**: Use format `feat(milestone-X): description, backtested`
8. **PUSH**: Push to branch `claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3`
9. **NEXT**: Update MILESTONES.md and move to next milestone

### Git Branch
All development happens on:
```
claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3
```

### Commit Message Format
```
feat(milestone-X): brief description, backtested

Detailed description of changes:
- What was implemented
- Architecture compliance
- Backtest results

File list:
- file1.dart (XX lines)
- file2.dart (XX lines)
```

---

## 🔑 Key Technologies

### Backend
- **Supabase**: Managed PostgreSQL + Auth + Storage + Edge Functions
- **PostgreSQL**: Main database with Row Level Security (RLS)
- **Deno**: TypeScript runtime for Edge Functions
- **Nominatim**: Reverse geocoding (OpenStreetMap)

### Frontend
- **Flutter**: Cross-platform UI framework (Web + Android)
- **Riverpod**: State management (flutter_riverpod)
- **go_router**: Declarative routing with auth guards
- **dio**: HTTP client for API calls
- **supabase_flutter**: Supabase client SDK
- **page_flip**: 3D page-turn animation package

---

## ⚠️ Common Pitfalls to Avoid

### 1. Smart Page Logic in Flutter
❌ **WRONG**: Computing layout types or color themes in Flutter
✅ **CORRECT**: Fetching pre-computed data from backend and rendering it

### 2. Feature Drift
❌ **WRONG**: Adding "helpful" features not in `v1Spez.md`
✅ **CORRECT**: Only implementing specified features

### 3. Over-Engineering
❌ **WRONG**: Creating abstractions "for future flexibility"
✅ **CORRECT**: Simple, direct implementations

### 4. Ignoring RLS
❌ **WRONG**: Assuming backend validates ownership
✅ **CORRECT**: RLS policies enforce user ownership at DB level

### 5. Forgetting to Backtest
❌ **WRONG**: Committing without verification
✅ **CORRECT**: Always verify against requirements before committing

---

## 📊 Database Schema Quick Reference

### Core Tables
- **users** (managed by Supabase Auth)
- **logs** (id, user_id, name, type)
- **entries** (id, log_id, event_date, highlight_text, location, Smart Page fields)
- **photos** (id, entry_id, url, thumbnail_url, dominant_colors, metadata)
- **tags** (id, name, category) - 19 seed tags
- **entry_tags** (entry_id, tag_id) - many-to-many

### Smart Page Fields on Entry
- `page_layout_type` (single_full, grid_2x2, grid_3x2)
- `color_theme` (warm_red, earth_green, ocean_blue, etc.)
- `sprinkles` (JSONB array of icon identifiers)
- `is_processed` (boolean flag)

### Optimized Views
- **entries_with_photos_and_tags** - Subquery aggregation for performance

---

## 🌐 Deployed Edge Functions

**Project ID**: `ikspskghylahtexiqepl`

**Function URLs**:
```
https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-logs
https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries
https://ikspskghylahtexiqepl.supabase.co/functions/v1/reverse-geocode
https://ikspskghylahtexiqepl.supabase.co/functions/v1/process-photo
https://ikspskghylahtexiqepl.supabase.co/functions/v1/compute-colors
https://ikspskghylahtexiqepl.supabase.co/functions/v1/compute-smart-page
```

**Status**: ✅ All deployed and operational

---

## 🚀 Quick Start for New AI Assistant

If you're an AI assistant starting a new session on this project:

1. **Read this file first** (you're doing it! ✅)
2. **Read** [`docs/v1Spez.md`](docs/v1Spez.md) - Product requirements
3. **Read** [`docs/architecture.md`](docs/architecture.md) - Technical architecture
4. **Read** [`MILESTONES.md`](MILESTONES.md) - Development roadmap
5. **Check** current milestone status (currently between MILESTONE 8 and 9)
6. **Review** the next milestone's implementation steps in MILESTONES.md
7. **Follow** the standard workflow: READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → PUSH

---

## 📞 Important Notes

### Environment Variables
- Supabase credentials should NEVER be committed
- Use `--dart-define` for Flutter or environment variables
- Backend functions use Supabase secrets

### Testing Strategy
- Manual testing for V1 (automated tests in V2)
- Test auth flow: signup → login → logout
- Test each CRUD operation
- Verify RLS policies work (User A can't access User B's data)

### Performance Targets
- API response times < 1 second
- Flipbook smooth page turns (60fps)
- Photo uploads < 5 seconds
- Web build size < 10 MB

---

## 📈 Progress Tracking

**Current Status**: 8/12 milestones completed (66.7%)

```
[████████████████████████████░░░░░░░░░░░░] 66.7%

✅ MILESTONE 0: Project Foundation
✅ MILESTONE 1: Flutter App Init
✅ MILESTONE 2: Backend Structure
✅ MILESTONE 3: Database Schema
✅ MILESTONE 4: Logs REST API
✅ MILESTONE 5: Entries REST API
✅ MILESTONE 6: Worker Functions
✅ MILESTONE 7: Smart Pages Engine
✅ MILESTONE 8: Flutter Auth UI
⏳ MILESTONE 9: Flutter Logs Feature    ← YOU ARE HERE
⏳ MILESTONE 10: Flutter Entries Feature
⏳ MILESTONE 11: Flipbook Viewer
⏳ MILESTONE 12: Integration Testing
```

**Next Action**: Implement MILESTONE 9 (Flutter Logs Feature)

---

## 🎓 Learning Resources

If you need to understand specific concepts:

- **Supabase Edge Functions**: https://supabase.com/docs/guides/functions
- **Supabase Auth**: https://supabase.com/docs/guides/auth
- **Flutter Riverpod**: https://riverpod.dev/docs/introduction/getting_started
- **go_router**: https://pub.dev/packages/go_router
- **RLS Policies**: https://supabase.com/docs/guides/auth/row-level-security

---

## ✅ Checklist Before Every Commit

- [ ] Read requirements in `v1Spez.md` for this milestone
- [ ] Verified architecture compliance (backend authoritative, frontend lean)
- [ ] No Smart Page logic in Flutter code
- [ ] No feature drift (only specified features)
- [ ] Code follows clean architecture pattern
- [ ] All imports and paths correct
- [ ] Error handling in place
- [ ] Loading states shown to user
- [ ] Backtested against requirements
- [ ] Commit message follows format
- [ ] Pushing to correct branch

---

**Last Updated**: After MILESTONE 8 completion and Edge Functions deployment
**Next Milestone**: MILESTONE 9 (Flutter Logs Feature)
**Project Status**: Backend complete ✅, Auth complete ✅, Ready for feature development
