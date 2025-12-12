// TogetherLog - App Router Configuration
// Handles navigation and auth-based redirects using go_router

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/logs/logs_screen.dart';
import '../../features/entries/entries_screen.dart';
import '../../features/entries/entry_create_screen.dart';
import '../../features/entries/entry_detail_screen.dart';
import '../../features/entries/entry_edit_screen.dart';
import '../../features/flipbook/flipbook_viewer.dart';

/// Router provider for the app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.whenOrNull(
        data: (user) => user != null,
      ) ??
          false;

      final isAuthRoute = state.matchedLocation == '/auth';

      // Redirect to auth if not logged in and not already on auth route
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth';
      }

      // Redirect to logs if logged in and on auth route
      if (isLoggedIn && isAuthRoute) {
        return '/logs';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth Route
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Logs Route (home for authenticated users)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/logs',
      ),
      GoRoute(
        path: '/logs',
        name: 'logs',
        builder: (context, state) => const LogsScreen(),
      ),

      // Entries routes
      GoRoute(
        path: '/logs/:logId/entries',
        name: 'entries',
        builder: (context, state) {
          final logId = state.pathParameters['logId']!;
          return EntriesScreen(logId: logId);
        },
      ),

      // Create entry route
      GoRoute(
        path: '/logs/:logId/entries/create',
        name: 'entry-create',
        builder: (context, state) {
          final logId = state.pathParameters['logId']!;
          return EntryCreateScreen(logId: logId);
        },
      ),

      // Entry detail route
      GoRoute(
        path: '/entries/:entryId',
        name: 'entry-detail',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return EntryDetailScreen(entryId: entryId);
        },
      ),

      // Entry edit route
      GoRoute(
        path: '/entries/:entryId/edit',
        name: 'entry-edit',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return EntryEditScreen(entryId: entryId);
        },
      ),

      // Flipbook route
      GoRoute(
        path: '/logs/:logId/flipbook',
        name: 'flipbook',
        builder: (context, state) {
          final logId = state.pathParameters['logId']!;
          final logName = state.uri.queryParameters['logName'] ?? 'Flipbook';
          return FlipbookViewer(
            logId: logId,
            logName: logName,
          );
        },
      ),
    ],
  );
});
