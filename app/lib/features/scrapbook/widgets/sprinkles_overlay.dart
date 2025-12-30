// TogetherLog - Sprinkles Overlay Widget
// Renders decorative icons from Smart Page sprinkles data

import 'package:flutter/material.dart';

/// Sprinkles overlay - displays decorative icons computed by backend
/// Icons are positioned strategically on the page
class SprinklesOverlay extends StatelessWidget {
  const SprinklesOverlay({
    super.key,
    required this.sprinkles,
    required this.colorScheme,
  });

  final List<String>? sprinkles;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (sprinkles == null || sprinkles!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Take max 3 sprinkles as per backend logic
    final displaySprinkles = sprinkles!.take(3).toList();

    return Stack(
      children: [
        // Position sprinkles strategically across the page
        for (int i = 0; i < displaySprinkles.length; i++)
          _buildSprinkleIcon(displaySprinkles[i], i, displaySprinkles.length),
      ],
    );
  }

  Widget _buildSprinkleIcon(String sprinkle, int index, int total) {
    final icon = _getSprinkleIcon(sprinkle);
    final position = _getSprinklePosition(index, total);

    return Positioned(
      top: position['top'],
      right: position['right'],
      bottom: position['bottom'],
      left: position['left'],
      child: Opacity(
        opacity: 0.15,
        child: Icon(
          icon,
          size: 80,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  /// Map sprinkle identifier to Flutter icon
  IconData _getSprinkleIcon(String sprinkle) {
    switch (sprinkle) {
      case 'heart':
        return Icons.favorite;
      case 'mountain':
        return Icons.terrain;
      case 'beach':
        return Icons.beach_access;
      case 'airplane':
        return Icons.flight;
      case 'utensils':
        return Icons.restaurant;
      case 'balloon':
        return Icons.celebration;
      case 'star':
        return Icons.star;
      default:
        return Icons.auto_awesome; // Fallback icon
    }
  }

  /// Calculate position for sprinkle based on index
  /// Distributes icons across different corners/edges of the page
  Map<String, double?> _getSprinklePosition(int index, int total) {
    // Position patterns for different sprinkle counts
    final positions = [
      // First sprinkle - top right
      {'top': 40.0, 'right': 40.0, 'bottom': null, 'left': null},
      // Second sprinkle - bottom left
      {'top': null, 'right': null, 'bottom': 40.0, 'left': 40.0},
      // Third sprinkle - top left
      {'top': 40.0, 'right': null, 'bottom': null, 'left': 40.0},
    ];

    if (index < positions.length) {
      return positions[index];
    }

    // Fallback position (should not be reached given max 3 sprinkles)
    return {'top': 40.0, 'right': 40.0, 'bottom': null, 'left': null};
  }
}
