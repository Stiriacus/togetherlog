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
   - Copy `.env.example` to `.env`
   - Add your Supabase URL and anon key

3. Run the app:
   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d <device-id>
   ```

## Development

- Follow clean architecture principles
- Keep UI logic separate from business logic
- Use Riverpod providers for state management
- All Smart Page logic is handled by the backend

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
