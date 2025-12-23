// TogetherLog - Polaroid Photo Widget for Flipbook
// Displays a photo with a Polaroid frame effect and stable random rotation

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Polaroid-style photo widget with stable random rotation
/// Used in flipbook layouts for scrapbook aesthetic
class PolaroidPhoto extends StatefulWidget {
  const PolaroidPhoto({
    required this.photoUrl,
    required this.colorScheme,
    this.size = 180.0,
    super.key,
  });

  final String photoUrl;
  final ColorScheme colorScheme;
  final double size;

  @override
  State<PolaroidPhoto> createState() => _PolaroidPhotoState();
}

class _PolaroidPhotoState extends State<PolaroidPhoto> {
  // Stable random rotation - generated once and cached
  late final double _rotationAngle;

  @override
  void initState() {
    super.initState();
    // Generate rotation once during initialization
    // Range: -6° to +6° converted to radians
    // Use URL hash for deterministic randomness per photo
    final random = math.Random(widget.photoUrl.hashCode);
    final degrees = -6.0 + random.nextDouble() * 12.0;
    _rotationAngle = degrees * (math.pi / 180.0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _rotationAngle,
      child: Container(
        width: widget.size,
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
                    imageUrl: widget.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: widget.colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: Icon(
                        Icons.broken_image,
                        size: 32,
                        color: widget.colorScheme.onSurface.withValues(alpha: 0.3),
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
