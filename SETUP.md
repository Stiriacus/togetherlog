# TogetherLog - Development Setup Guide

## Prerequisites

### Required Tools
- **Flutter SDK** (latest stable) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Supabase CLI** - [Install Supabase CLI](https://supabase.com/docs/guides/cli)
- **Git**

### Optional Tools
- **Deno** (for local Edge Function testing)
- **Docker** (for self-hosted Supabase)

---

## Initial Setup

### 1. Flutter App Initialization

The `/app` folder contains the Flutter source code structure, but platform-specific files need to be generated:

```bash
cd app

# Initialize Flutter platform files (only needed once)
flutter create . --org com.togetherlog --platforms web,android

# This will generate:
# - android/     (Android platform files)
# - web/         (Web platform files)
# - ios/         (iOS platform files, on macOS)
# - linux/       (Linux platform files)
# - windows/     (Windows platform files)
# - macos/       (macOS platform files)

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
```

**Note**: The `flutter create` command will NOT overwrite existing files in `lib/`, so your source code is safe.

### 2. Environment Configuration

#### Flutter App
```bash
cd app
cp .env.example .env
# Edit .env and add your Supabase credentials
```

#### Backend
```bash
cd backend
cp .env.example .env
# Edit .env and add your Supabase credentials
```

### 3. Supabase Project Setup

#### Option A: Using Supabase Cloud (Recommended for V1)

1. Create a new project at [supabase.com](https://supabase.com)
2. Select EU region (for GDPR compliance)
3. Copy your project URL and anon key
4. Update `.env` files in both `/app` and `/backend`

#### Option B: Local Development

```bash
cd backend
supabase init
supabase start
```

### 4. Database Migrations

```bash
cd backend
supabase db push
```

This will apply all migrations from `/backend/sql/migrations/`.

### 5. Deploy Edge Functions

```bash
cd backend
supabase functions deploy
```

---

## Running the App

### Development Mode

#### Web
```bash
cd app
flutter run -d chrome
```

#### Android
```bash
cd app
flutter run -d <device-id>

# List available devices
flutter devices
```

### Production Build

#### Web
```bash
cd app
flutter build web --release
# Output: build/web/
```

#### Android APK
```bash
cd app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
cd app
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Development Workflow

### Backend Changes

1. Modify Edge Functions in `/backend/edge-functions/`
2. Test locally:
   ```bash
   supabase functions serve <function-name>
   ```
3. Deploy:
   ```bash
   supabase functions deploy <function-name>
   ```

### Database Schema Changes

1. Create new migration:
   ```bash
   supabase migration new <migration-name>
   ```
2. Edit the migration file in `/backend/sql/migrations/`
3. Apply migration:
   ```bash
   supabase db push
   ```

### Flutter App Changes

1. Modify code in `/app/lib/`
2. Hot reload: Press `r` in terminal or save file in IDE
3. Full restart: Press `R` in terminal

---

## Troubleshooting

### Flutter Doctor Issues
```bash
flutter doctor -v
# Follow the recommendations to fix any issues
```

### Supabase Connection Issues
- Verify your Supabase URL and anon key in `.env`
- Check that your Supabase project is running
- Ensure Edge Functions are deployed

### Build Issues
```bash
# Clean build cache
cd app
flutter clean
flutter pub get
flutter build <platform>
```

---

## Project Status

### Completed Milestones
- ✅ MILESTONE 0: Project foundation and folder structure

### Current Milestone
- 🔄 MILESTONE 1: Flutter app initialization (requires Flutter SDK)
- 🔄 MILESTONE 3: Database schema and migrations

### Upcoming
- MILESTONE 4-7: Backend API and workers
- MILESTONE 8-11: Flutter UI implementation
- MILESTONE 12: Integration testing

---

## Architecture Overview

```
TogetherLog/
├── app/               # Flutter frontend (Web + Android)
├── backend/           # Supabase backend (Edge Functions + SQL)
├── docs/              # Specifications and architecture
└── SETUP.md           # This file
```

For detailed architecture information, see [docs/architecture.md](docs/architecture.md).

---

## License

MIT - See [LICENSE](LICENSE) for details.
