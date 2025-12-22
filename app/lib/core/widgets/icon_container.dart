// TogetherLog - Icon Container Component
// Enforces icon container contract from Design Tokens.md

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Icon container widget per Design Tokens.md icon container contract
///
/// Usage rules:
/// - Allowed only for: primary action buttons, inline actions, FAB, active navigation
/// - Background: slightly darker than surface
/// - Radius: rMd (10)
/// - Padding: xs (4) for small, sm (8) for standard
/// - Elevation: e2
/// - Icon centered, never edge-aligned
class IconContainer extends StatelessWidget {
  const IconContainer({
    required this.icon,
    this.size = AppIconSize.standard,
    this.isActive = true,
    super.key,
  });

  final IconData icon;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    // Only render if active or context is primary action
    if (!isActive) {
      return Icon(icon, size: size);
    }

    // Determine padding based on size
    final padding = size <= AppIconSize.small
        ? AppSpacing.xs
        : AppSpacing.sm;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        // Slightly darker than surface per Design Tokens.md
        color: AppColors.oliveWood.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.rMd),
        boxShadow: AppShadows.elevation2,
      ),
      child: Icon(
        icon,
        size: size,
        color: AppColors.carbonBlack,
      ),
    );
  }
}
