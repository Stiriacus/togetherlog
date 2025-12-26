// TogetherLog - Icon Mapping Service
// Maps sprinkle icon names from backend to Material Icons

import 'package:flutter/material.dart';

/// Service for mapping icon names to Material Icons
/// Centralizes icon mapping logic for sprinkles/decorative icons
class IconMappingService {
  IconMappingService._(); // Private constructor - static class only

  /// Map icon name from backend to Material IconData
  /// Returns Icons.star as fallback for unknown icon names
  static IconData getIconFromName(String iconName) {
    switch (iconName) {
      case 'favorite':
      case 'heart':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'local_florist':
      case 'flower':
        return Icons.local_florist;
      case 'cake':
        return Icons.cake;
      case 'beach_access':
      case 'beach':
        return Icons.beach_access;
      case 'terrain':
      case 'mountain':
        return Icons.terrain;
      case 'flight':
      case 'airplane':
        return Icons.flight;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard;
      case 'celebration':
      case 'balloon':
        return Icons.celebration;
      case 'music_note':
      case 'music':
        return Icons.music_note;
      case 'camera':
        return Icons.camera_alt;
      case 'palette':
      case 'art':
        return Icons.palette;
      case 'sports_soccer':
      case 'soccer':
        return Icons.sports_soccer;
      case 'nightlife':
      case 'local_bar':
        return Icons.local_bar;
      case 'pets':
      case 'pet':
        return Icons.pets;
      default:
        return Icons.star; // Fallback icon
    }
  }
}
