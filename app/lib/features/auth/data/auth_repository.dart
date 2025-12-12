// TogetherLog - Authentication Repository
// Handles all Supabase Auth operations

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/api/supabase_client.dart';
import '../../../data/models/user.dart';

class AuthRepository {
  /// Sign in with email and password
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      return AppUser(
        id: response.user!.id,
        email: response.user!.email ?? email,
        createdAt: DateTime.tryParse(response.user!.createdAt),
      );
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      return AppUser(
        id: response.user!.id,
        email: response.user!.email ?? email,
        createdAt: DateTime.tryParse(response.user!.createdAt),
      );
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user
  AppUser? getCurrentUser() {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  /// Stream of auth state changes
  Stream<AppUser?> authStateChanges() {
    return supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;

      return AppUser(
        id: user.id,
        email: user.email ?? '',
        createdAt: DateTime.tryParse(user.createdAt),
      );
    });
  }
}
