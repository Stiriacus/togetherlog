// TogetherLog - Authentication Providers (Riverpod)
// Manages auth state and provides auth repository

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../data/auth_repository.dart';

/// Provider for AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for current auth state (stream)
/// Returns current authenticated user or null if not authenticated
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Provider for current user (synchronous access)
/// Useful for guards and synchronous checks
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
