# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TogetherLog** is a Flutter-based flipbook application for preserving shared memories, backed by Supabase. The core innovation is the **Smart Pages Engine** - a backend-authoritative system that automatically generates beautiful page layouts based on photos, tags, and emotions.

- **Frontend**: Flutter (Web + Android)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)

## Essential Reading

Before working on this codebase, read these files **in order**:

1. **`docs/v1Spez.md`** - Complete product requirements for V1 MVP
2. **`docs/architecture.md`** - System architecture and technical decisions
3. **`docs/design-system.md`** - Authoritative design contract for app chrome styling

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

---

## Platform & Execution Rules (MANDATORY)

### Platform Testing Constraints

Claude Code must ONLY run and test the Flutter **Web** application.

**Allowed platform:**
- **Web (Chrome)** via Brave executable

**Prohibited platforms (never use):**
- Windows, macOS, Linux desktop
- Android, iOS
- Web Server device (unless explicitly instructed)

Claude Code must NEVER attempt to:
- Select or use any non-Web device
- Run `flutter devices`
- Run desktop, mobile, or server builds

### Flutter Web Execution Rule

TogetherLog MUST always be run using the Brave-based Chrome command:

```bash
CHROME_EXECUTABLE=$(which brave-browser || which brave) flutter run -d chrome
```

Claude Code must NEVER use:
- `flutter run -d chrome`
- or any other `flutter run -d <device>` variant

This Brave-based command is the ONLY valid way to run the Flutter app during development.

### Flutter Color API Rule

TogetherLog uses the modern Flutter Material 3 color API.

**ALWAYS use:**
```dart
color.withValues(alpha: X)
```

**NEVER generate:**
```dart
color.withOpacity(X)  // FORBIDDEN
```

If an existing file contains `withOpacity()`, migrate it to `withValues(alpha: …)` when modifying that file.

---

## Common Development Commands

### Flutter App

```bash
# Navigate to app directory
cd app

# Get dependencies
flutter pub get

# Run on web (MANDATORY - use Brave browser)
CHROME_EXECUTABLE=$(which brave-browser || which brave) flutter run -d chrome

# Build for production
flutter build web --release

# Clean build cache
flutter clean && flutter pub get

# Check for analyzer issues
flutter analyze
```

### Backend (Supabase)

```bash
# Navigate to backend directory
cd backend

# Apply database migrations
supabase db push

# Deploy all Edge Functions
supabase functions deploy

# Deploy specific function
supabase functions deploy <function-name>

# Create new migration
supabase migration new <migration-name>
```

### Git Workflow

```bash
# All development happens on this branch:
git checkout claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3

# Commit format:
git commit -m "feat: brief description"

# Push to branch
git push origin claude/implement-togetherlog-milestones-01VZCHt2jn2mHfHykS74GcA3
```

---

## Project Structure

### Backend
```
backend/supabase/
├── functions/              # Edge Functions (TypeScript/Deno)
│   ├── api-logs/           # Logs CRUD REST API
│   ├── api-entries/        # Entries CRUD REST API
│   ├── reverse-geocode/    # GPS → location worker
│   ├── process-photo/      # EXIF extraction worker
│   ├── compute-colors/     # Color analysis worker
│   └── compute-smart-page/ # Smart Pages Engine
└── migrations/             # PostgreSQL schema migrations
```

### Frontend
```
app/lib/
├── core/                   # Routing, theme, utilities
├── data/                   # API clients, models, repositories
└── features/               # Feature-based modules
    ├── auth/               # Authentication
    ├── logs/               # Logs CRUD
    ├── entries/            # Entries CRUD
    └── flipbook/           # Flipbook viewer
```

---

## Key Concepts

### Database Tables
- `users` - Managed by Supabase Auth
- `logs` - User's memory books
- `entries` - Individual memories (with Smart Page fields)
- `photos` - Entry photos (with EXIF metadata)
- `tags` - Predefined tags (19 seed tags)
- `entry_tags` - Many-to-many relationship

**Row Level Security (RLS):** Users can only access their own data (enforced at PostgreSQL level).

### Smart Pages Engine

**Location:** `backend/supabase/functions/compute-smart-page/index.ts`

Runs **entirely on the backend** and applies three rule engines:

1. **Layout Type Selection** (based on photo count)
   - 0-1 photos → `single_full`
   - 2-4 photos → `grid_2x2`
   - 5-6 photos → `grid_3x2`

2. **Color Theme Selection** (tag-based priority)
   - Romantic/In Love → `warm_red`
   - Nature/Hiking → `earth_green`
   - Lake/Beach → `ocean_blue`
   - Nightlife → `deep_purple`
   - Food/Home → `warm_earth`
   - Travel → `soft_rose`
   - Fallback → Dominant photo color or `neutral`

3. **Sprinkles Selection** (tag-to-icon mapping, max 3)

**Flutter's Job:** Render the pre-computed layout. **No computation.**

---

## Testing Strategy

**All testing is manual** for V1 (no automated UI tests).

See `docs/testing-guide.md` for comprehensive procedures:
- Auth flow (signup → login → logout)
- CRUD operations (logs, entries)
- RLS policies verification
- Photo upload to Supabase Storage
- Smart Page computation validation
- Flipbook page-turn performance

---

## Technology Stack

**Frontend:**
- Flutter 3.32.5 (Web + Android)
- Riverpod 2.4.0 (state management)
- go_router 13.0.0 (routing with auth guards)
- dio 5.4.0 (HTTP client)
- supabase_flutter 2.0.0 (Supabase SDK)
- image_picker 1.0.7 (photo selection)

**Backend:**
- Supabase PostgreSQL (EU region, GDPR compliant)
- Supabase Auth (email/password)
- Supabase Storage (EU region)
- Supabase Edge Functions (TypeScript/Deno)
- OpenStreetMap/Nominatim (reverse geocoding)

---

## Common Pitfalls to Avoid

### 1. Smart Page Logic in Flutter
- ❌ **WRONG:** Computing layout types or color themes in Flutter
- ✅ **CORRECT:** Fetching pre-computed data from backend and rendering it

### 2. Feature Drift
- ❌ **WRONG:** Adding "helpful" features not in `v1Spez.md`
- ✅ **CORRECT:** Only implementing specified features

### 3. Over-Engineering
- ❌ **WRONG:** Creating abstractions "for future flexibility"
- ✅ **CORRECT:** Simple, direct implementations

### 4. Ignoring RLS
- ❌ **WRONG:** Assuming backend validates ownership via app logic
- ✅ **CORRECT:** RLS policies enforce user ownership at database level

### 5. Forgetting to Backtest
- ❌ **WRONG:** Committing without verification against requirements
- ✅ **CORRECT:** Always verify against `v1Spez.md` before committing

---

## Documentation Structure

**Single Source of Truth:** The `/docs` directory contains all technical specifications. No nested READMEs exist.

### Core Specifications
- `docs/v1Spez.md` - Product specification (source of truth for features)
- `docs/architecture.md` - Technical architecture and system design
- `docs/design-system.md` - UI design contract (colors, typography, spacing, patterns)
- `docs/testing-guide.md` - Manual testing guide
- `docs/CHANGES.md` - Implementation changelog (append-only, self-documenting)
- `docs/v2optional.md` - V2+ feature proposals

### Planning Documents (`/docs/planning/`)

**Active planning work** for upcoming features and changes.

**Structure:**
- Files placed **directly in `/docs/planning/`** (flat structure)
- File naming: `feature-name.md`, `migration-name.md`
- When complete: move to `/docs/archive/`

**Purpose:**
- Contains feature requests and changes that are **next to do**
- Default work queue unless explicitly instructed otherwise
- Planning files represent committed next steps

**Current planning files:**
- `flipbook-fade-transition.md` - Smooth fade during page swipe
- `backend-photo-layout-coordinates.md` - Backend-authoritative layout coordinates

---

## Deployed Supabase Project

- **Project ID:** `ikspskghylahtexiqepl`
- **Region:** EU (GDPR compliant)
- **Status:** All Edge Functions deployed and operational
- **API Base URL:** `https://ikspskghylahtexiqepl.supabase.co/functions/v1/`

---

## Forbidden Behavior (MANDATORY)

Claude Code must NEVER:
- Attempt to run native desktop (Linux/macOS/Windows) builds
- Attempt to run Android or iOS builds
- Attempt to use `flutter devices`
- Attempt to auto-launch any browser
- Attempt to generate or modify v2optional features
- Attempt to create automated UI or E2E tests
- Attempt to bypass backend-authoritative rules

All testing is manual unless otherwise specified. Claude Code must NOT attempt automated UI testing or automated browser interactions.

---

**License:** MIT - See `LICENSE` file
