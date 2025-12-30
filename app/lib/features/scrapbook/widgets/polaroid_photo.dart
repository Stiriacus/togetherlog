// TogetherLog - Polaroid Photo Widget for Scrapbook
// Displays a photo with a Polaroid frame effect and stable random rotation

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Polaroid-style photo widget with stable random rotation
/// Used in scrapbook layouts for scrapbook aesthetic
class PolaroidPhoto extends StatelessWidget {
  const PolaroidPhoto({
    required this.photoUrl,
    required this.colorScheme,
    this.size = 180.0,
    this.layoutVariant = 0,
    super.key,
  });

  final String photoUrl;
  final ColorScheme colorScheme;
  final double size;
  final int layoutVariant;

  /// Calculate rotation angle based on photo URL and layoutVariant
  /// Range: -6° to +6° converted to radians
  double _getRotationAngle() {
    final seed = photoUrl.hashCode + layoutVariant;
    final random = math.Random(seed);
    final degrees = -6.0 + random.nextDouble() * 12.0;
    return degrees * (math.pi / 180.0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _getRotationAngle(),
      child: Container(
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(4, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo area with top and side margins
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: Icon(
                        Icons.broken_image,
                        size: 32,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Polaroid "chin" - thick bottom padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
