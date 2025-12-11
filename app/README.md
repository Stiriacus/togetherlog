# TogetherLog Flutter App

This is the Flutter frontend for TogetherLog, supporting Web and Android platforms.

## Tech Stack

- **Flutter** (Web + Android)
- **go_router** for navigation
- **flutter_riverpod** for state management
- **dio** for HTTP requests
- **Supabase Flutter SDK** for auth and storage

## Project Structure

```
lib/
├── features/
│   ├── auth/          # Authentication UI and logic
│   ├── logs/          # Log list, create, edit
│   ├── entries/       # Entry creation, editing
│   └── flipbook/      # Flipbook viewer with 3D page-turn
├── core/
│   ├── theme/         # Global theming + dynamic page themes
│   ├── routing/       # go_router configuration
│   └── widgets/       # Reusable UI components
└── data/
    ├── api/           # REST API clients
    └── models/        # Data models
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (comes with Flutter)

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Supabase:

   **Option A: Environment Variables (Recommended)**
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

   **Option B: Update main.dart**
   Edit `lib/main.dart` and replace the placeholder values with your actual Supabase credentials.

   **⚠️ Warning**: Never commit actual credentials to version control!

3. Run the app:
   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d <device-id>
   ```

## Development Status

### Completed Milestones

- ✅ **MILESTONE 8**: Authentication UI and state management
  - Email/password login and signup with Supabase Auth
  - Riverpod providers for auth state
  - go_router with auth-based redirects
  - Clean architecture (data/features/core separation)

### Pending Milestones

- ⏳ **MILESTONE 9**: Logs feature (list, create, edit)
- ⏳ **MILESTONE 10**: Entries feature (create, upload, edit)
- ⏳ **MILESTONE 11**: Flipbook viewer with 3D page-turn animation
- ⏳ **MILESTONE 12**: Integration testing and final validation

## Development Principles

- Follow clean architecture principles
- Keep UI logic separate from business logic
- Use Riverpod providers for state management
- All Smart Page logic is handled by the backend
- Backend authoritative - client only renders

## Building

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## License

MIT
