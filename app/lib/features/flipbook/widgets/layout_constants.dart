// TogetherLog - Pixel-Perfect Layout Constants
// Defines exact pixel boxes for flipbook page layouts at 874×1240 (DIN A5 at 150 DPI)
//
// IMPORTANT CONSTRAINTS:
// - Date Box: FIXED position and size (do not modify)
// - Text Box: FIXED position and size (do not modify)
// - Content Box: HARD BOUNDARY - all content (photos, maps) MUST fit inside
//   - No content may overflow the content box boundaries
//   - Whether 1 photo, 2 photos, 3 photos, or photo+map - stays inside
//   - Content box is the absolute limit for all visual elements

import 'dart:ui';

/// Flipbook page layout constants - all measurements in pixels
class LayoutConstants {
  // Page Dimensions (DIN A5 at 150 DPI)
  static const double pageWidth = 874.0;
  static const double pageHeight = 1240.0;

  // Frame & Padding
  static const double framePaddingHorizontal = 74.0;
  static const double framePaddingVertical = 48.0;

  // Content area (inside frame): 726 × 1144 px
  static const double contentAreaWidth = pageWidth - (framePaddingHorizontal * 2);
  static const double contentAreaHeight = pageHeight - (framePaddingVertical * 2);

  // Date Box (Top, centered)
  static const Rect dateBox = Rect.fromLTWH(
    framePaddingHorizontal * 4.15, // x: ~307 (centered)
    100.0,
    contentAreaWidth / 3, // width: ~242
    60.0,
  );

  static const double dateFontSize = 32.0;

  // Content Box (Middle) - Photos/Maps

  /// Single Full Layout - one large photo or map
  static const Rect singleContentBox = Rect.fromLTWH(
    framePaddingHorizontal, // x: 74
    230.0,
    contentAreaWidth, // width: 726
    740.0,
  );

  /// 2×1 Layout - Photo (left)
  /// Base position - can be offset randomly in the layout
  static const Rect twoByOnePhotoBoxBase = Rect.fromLTWH(
    84.0,
    430.0, // Moved down 200px from 230
    340.0,
    480.0,
  );

  /// 2×1 Layout - Location Map (right)
  /// Base position - can be offset randomly in the layout
  static const Rect twoByOneMapBoxBase = Rect.fromLTWH(
    450.0,
    430.0, // Moved down 200px from 230
    340.0,
    480.0,
  );

  /// Vertical offset for staggered positioning in 2×1 layout
  /// One element will be moved up by this amount for depth
  static const double twoByOneVerticalOffset = 50.0;

  // Text Box (Bottom, centered)
  static const Rect textBox = Rect.fromLTWH(
    200.0,
    980.0,
    474.0,
    160.0,
  );

  static const double textFontSize = 28.0;
  static const double textLineHeight = 1.3;
  static const int textMaxLines = 3;

  // Polaroid Sizes
  static const double polaroidSizeLarge = 420.0;
  static const double polaroidSizeMedium = 340.0;
}
