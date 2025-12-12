// TogetherLog - Smart Page Theme Builder
// Maps backend color theme identifiers to Flutter color schemes

import 'package:flutter/material.dart';

/// Smart Page color theme mappings
/// These themes are computed by the backend Smart Pages Engine
/// and the client only applies the provided theme identifier
class SmartPageTheme {
  /// Get ColorScheme for a given theme identifier
  /// Returns neutral theme if identifier is null or unknown
  static ColorScheme getColorScheme(String? themeId) {
    switch (themeId) {
      case 'warm_red':
        return _warmRedTheme;
      case 'earth_green':
        return _earthGreenTheme;
      case 'ocean_blue':
        return _oceanBlueTheme;
      case 'deep_purple':
        return _deepPurpleTheme;
      case 'warm_earth':
        return _warmEarthTheme;
      case 'soft_rose':
        return _softRoseTheme;
      case 'neutral':
      default:
        return _neutralTheme;
    }
  }

  /// Warm Red Theme - Romantic, In Love, Anniversary
  static const ColorScheme _warmRedTheme = ColorScheme.light(
    primary: Color(0xFFD32F2F), // Deep red
    secondary: Color(0xFFFF6B6B), // Warm coral red
    surface: Color(0xFFFFF0F0), // Soft pink background
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF5D1010), // Dark red text
  );

  /// Earth Green Theme - Nature & Hiking, Adventure
  static const ColorScheme _earthGreenTheme = ColorScheme.light(
    primary: Color(0xFF2E7D32), // Forest green
    secondary: Color(0xFF66BB6A), // Light green
    surface: Color(0xFFF1F8E9), // Very light green
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1B5E20), // Dark green text
  );

  /// Ocean Blue Theme - Lake, Beach
  static const ColorScheme _oceanBlueTheme = ColorScheme.light(
    primary: Color(0xFF0277BD), // Ocean blue
    secondary: Color(0xFF4FC3F7), // Sky blue
    surface: Color(0xFFE1F5FE), // Very light blue
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF01579B), // Dark blue text
  );

  /// Deep Purple Theme - Nightlife
  static const ColorScheme _deepPurpleTheme = ColorScheme.light(
    primary: Color(0xFF512DA8), // Deep purple
    secondary: Color(0xFF7E57C2), // Medium purple
    surface: Color(0xFFEDE7F6), // Very light purple
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF311B92), // Dark purple text
  );

  /// Warm Earth Theme - Food, Home
  static const ColorScheme _warmEarthTheme = ColorScheme.light(
    primary: Color(0xFF8D6E63), // Warm brown
    secondary: Color(0xFFBCAAA4), // Light brown
    surface: Color(0xFFEFEBE9), // Cream
    onPrimary: Colors.white,
    onSecondary: Color(0xFF3E2723),
    onSurface: Color(0xFF3E2723), // Dark brown text
  );

  /// Soft Rose Theme - Travel
  static const ColorScheme _softRoseTheme = ColorScheme.light(
    primary: Color(0xFFC2185B), // Rose
    secondary: Color(0xFFF06292), // Light pink
    surface: Color(0xFFFCE4EC), // Very light pink
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF880E4F), // Dark rose text
  );

  /// Neutral Theme - Default fallback
  static const ColorScheme _neutralTheme = ColorScheme.light(
    primary: Color(0xFF616161), // Medium gray
    secondary: Color(0xFF9E9E9E), // Light gray
    surface: Color(0xFFF5F5F5), // Very light gray
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
    onSurface: Color(0xFF212121), // Dark gray text
  );

  /// Get text style for highlight text based on theme
  static TextStyle getHighlightTextStyle(String? themeId) {
    final colorScheme = getColorScheme(themeId);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      height: 1.4,
    );
  }

  /// Get text style for metadata (location, date) based on theme
  static TextStyle getMetadataTextStyle(String? themeId) {
    final colorScheme = getColorScheme(themeId);
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.3,
    );
  }
}
