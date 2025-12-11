// TogetherLog - App Router Configuration
// Handles navigation and auth-based redirects using go_router

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/logs/logs_screen.dart';
import '../../features/entries/entries_screen.dart';

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

      // Entries route (placeholder for MILESTONE 10)
      GoRoute(
        path: '/logs/:logId/entries',
        name: 'entries',
        builder: (context, state) {
          final logId = state.pathParameters['logId']!;
          return EntriesScreen(logId: logId);
        },
      ),

      // Flipbook routes will be added in MILESTONE 11
    ],
  );
});
