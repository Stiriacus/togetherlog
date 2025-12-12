// TogetherLog - Smart Page Renderer Widget
// Renders an entry using backend-computed Smart Page layout and theme

import 'package:flutter/material.dart';
import '../../../core/theme/smart_page_theme.dart';
import '../../../data/models/entry.dart';
import 'layouts/single_full_layout.dart';
import 'layouts/grid_2x2_layout.dart';
import 'layouts/grid_3x2_layout.dart';
import 'sprinkles_overlay.dart';

/// Smart Page Renderer - renders an entry based on backend Smart Page data
/// IMPORTANT: This widget does NOT compute layouts or themes - it only renders
/// the pre-computed Smart Page data from the backend
class SmartPageRenderer extends StatelessWidget {
  const SmartPageRenderer({
    super.key,
    required this.entry,
  }) : customChild = null;

  /// Custom page constructor for non-entry pages (e.g., "The End" page)
  const SmartPageRenderer.customPage({
    super.key,
    required Widget child,
  })  : entry = null,
        customChild = child;

  final Entry? entry;
  final Widget? customChild;

  @override
  Widget build(BuildContext context) {
    // If custom child is provided, render it directly
    if (customChild != null) {
      return customChild!;
    }

    // Render entry-based page
    if (entry == null) {
      return Container(); // Fallback for invalid state
    }

    // Get color scheme from backend-computed theme
    final colorScheme = SmartPageTheme.getColorScheme(entry!.colorTheme);

    // Select layout widget based on backend-computed layout type
    final layoutWidget = _getLayoutWidget(colorScheme);

    return Stack(
      children: [
        // Layout widget (background)
        layoutWidget,

        // Sprinkles overlay (decorative icons)
        SprinklesOverlay(
          sprinkles: entry!.sprinkles,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  /// Select appropriate layout widget based on pageLayoutType
  /// Layout type is computed by backend Smart Pages Engine
  Widget _getLayoutWidget(ColorScheme colorScheme) {
    switch (entry!.pageLayoutType) {
      case 'single_full':
        return SingleFullLayout(
          entry: entry!,
          colorScheme: colorScheme,
        );
      case 'grid_2x2':
        return Grid2x2Layout(
          entry: entry!,
          colorScheme: colorScheme,
        );
      case 'grid_3x2':
        return Grid3x2Layout(
          entry: entry!,
          colorScheme: colorScheme,
        );
      default:
        // Fallback to single_full if layout type is null or unknown
        return SingleFullLayout(
          entry: entry!,
          colorScheme: colorScheme,
        );
    }
  }
}
