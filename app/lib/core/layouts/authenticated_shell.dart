// TogetherLog - Authenticated Shell Layout
// Implements canonical screen anatomy with navigation rail

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../navigation/app_navigation_rail.dart';

/// Shell layout for authenticated screens
/// Implements Structural UI Patterns.md canonical screen anatomy:
/// - Navigation Context (rail)
/// - Content area with max-width constraints
class AuthenticatedShell extends ConsumerWidget {
  const AuthenticatedShell({
    required this.child,
    required this.currentRoute,
    this.maxContentWidth = 960,
    super.key,
  });

  final Widget child;
  final String currentRoute;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation rail
          AppNavigationRail(
            currentRoute: currentRoute,
            onLogout: () async {
              await authRepository.signOut();
            },
          ),

          // Content area
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
