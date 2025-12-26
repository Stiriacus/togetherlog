// TogetherLog - Polaroid Map Widget for Scrapbook
// Displays a hand-drawn style map in a Polaroid frame with stable random rotation

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/entry.dart';

/// Polaroid-style map widget with stable random rotation
/// Used in scrapbook layouts for entries with location data
class PolaroidMap extends StatelessWidget {
  const PolaroidMap({
    required this.location,
    required this.colorScheme,
    this.size = 180.0,
    this.layoutVariant = 0,
    super.key,
  });

  final Location location;
  final ColorScheme colorScheme;
  final double size;
  final int layoutVariant;

  /// Calculate rotation angle based on location and layoutVariant
  /// Range: -6° to +6° converted to radians
  double _getRotationAngle() {
    final seed = location.displayName.hashCode + layoutVariant;
    final random = math.Random(seed);
    final degrees = -6.0 + random.nextDouble() * 12.0;
    return degrees * (math.pi / 180.0);
  }

  @override
  Widget build(BuildContext context) {
    // Default coordinates if GPS not available (center of map)
    final lat = location.lat ?? 48.8566; // Paris as default
    final lng = location.lng ?? 2.3522;
    final coordinates = LatLng(lat, lng);

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
            // Map area with top and side margins (same as photo)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: coordinates,
                      initialZoom: 13.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // Non-interactive
                      ),
                    ),
                    children: [
                      // Stamen Watercolor tiles for hand-drawn aesthetic
                      TileLayer(
                        urlTemplate:
                            'https://tiles.stadiamaps.com/tiles/stamen_watercolor/{z}/{x}/{y}.jpg',
                        userAgentPackageName: 'com.togetherlog.app',
                      ),
                      // Location pin marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: coordinates,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: colorScheme.primary,
                              size: 40,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Polaroid "chin" - location name caption
            Container(
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                location.displayName,
                style: GoogleFonts.justAnotherHand(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
