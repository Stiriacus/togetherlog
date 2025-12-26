// TogetherLog - Layout Data Models
// Immutable data structures for coordinate-based page layouts
// Supports V1 (auto-generated) and V2 (user-edited) layouts

import 'package:flutter/foundation.dart';
import 'dart:ui';

/// Type of item (photo or location map)
enum ItemType {
  photo,
  map,
}

/// Position and styling data for a single item (photo or map)
/// Used for both automated layout computation and user-edited positions
@immutable
class ItemLayoutData {
  /// Constructor
  const ItemLayoutData({
    required this.itemId,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    this.zIndex = 0,
  });

  /// Unique identifier (photo ID or "location")
  final String itemId;

  /// Type of item
  final ItemType type;

  /// X position (pixels from left edge of content area)
  final double x;

  /// Y position (pixels from top edge of content area)
  final double y;

  /// Width of the polaroid (including frame)
  final double width;

  /// Height of the polaroid (including caption space)
  final double height;

  /// Rotation angle in degrees (-5 to +5 for V1, -180 to +180 for V2)
  final double rotation;

  /// Z-index for layering (higher = in front)
  /// Default: 0 (for V1), can be adjusted in V2 editor
  final int zIndex;

  /// Copy with modified fields
  ItemLayoutData copyWith({
    String? itemId,
    ItemType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    int? zIndex,
  }) {
    return ItemLayoutData(
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// Get bounding box for collision detection
  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemLayoutData &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          type == other.type &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          rotation == other.rotation &&
          zIndex == other.zIndex;

  @override
  int get hashCode =>
      itemId.hashCode ^
      type.hashCode ^
      x.hashCode ^
      y.hashCode ^
      width.hashCode ^
      height.hashCode ^
      rotation.hashCode ^
      zIndex.hashCode;

  @override
  String toString() =>
      'ItemLayoutData(id: $itemId, type: $type, pos: ($x,$y), size: ${width}x$height, rot: $rotation°, z: $zIndex)';
}

/// Position and styling data for decorative icons (sprinkles)
@immutable
class IconLayoutData {
  const IconLayoutData({
    required this.iconName,
    required this.x,
    required this.y,
    required this.rotation,
    this.size = 32.0,
    this.zIndex = -1,
  });

  /// Icon name (e.g., 'heart', 'star', 'mountain')
  final String iconName;

  /// X position (pixels from left edge of content area)
  final double x;

  /// Y position (pixels from top edge of content area)
  final double y;

  /// Rotation angle in degrees (-15 to +15 for V1)
  final double rotation;

  /// Icon size (default: 32px)
  final double size;

  /// Z-index for layering (default: -1 to place behind photos)
  final int zIndex;

  /// Copy with modified fields
  IconLayoutData copyWith({
    String? iconName,
    double? x,
    double? y,
    double? rotation,
    double? size,
    int? zIndex,
  }) {
    return IconLayoutData(
      iconName: iconName ?? this.iconName,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// Get bounding box for collision detection
  Rect get boundingBox => Rect.fromLTWH(x, y, size, size);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IconLayoutData &&
          runtimeType == other.runtimeType &&
          iconName == other.iconName &&
          x == other.x &&
          y == other.y &&
          rotation == other.rotation &&
          size == other.size &&
          zIndex == other.zIndex;

  @override
  int get hashCode =>
      iconName.hashCode ^
      x.hashCode ^
      y.hashCode ^
      rotation.hashCode ^
      size.hashCode ^
      zIndex.hashCode;

  @override
  String toString() =>
      'IconLayoutData(icon: $iconName, pos: ($x,$y), size: $size, rot: $rotation°, z: $zIndex)';
}

/// Position data for text block
@immutable
class TextBlockLayout {
  const TextBlockLayout({
    required this.y,
    required this.maxWidth,
    this.zIndex = 10,
  });

  /// Y position (pixels from top edge of content area)
  /// X is calculated to center the text
  final double y;

  /// Maximum width for text wrapping
  final double maxWidth;

  /// Z-index for layering (default: 10 to place on top)
  final int zIndex;

  /// Copy with modified fields
  TextBlockLayout copyWith({
    double? y,
    double? maxWidth,
    int? zIndex,
  }) {
    return TextBlockLayout(
      y: y ?? this.y,
      maxWidth: maxWidth ?? this.maxWidth,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextBlockLayout &&
          runtimeType == other.runtimeType &&
          y == other.y &&
          maxWidth == other.maxWidth &&
          zIndex == other.zIndex;

  @override
  int get hashCode => y.hashCode ^ maxWidth.hashCode ^ zIndex.hashCode;

  @override
  String toString() =>
      'TextBlockLayout(y: $y, maxWidth: $maxWidth, z: $zIndex)';
}

/// Complete page layout data
/// Contains all positioned elements for a scrapbook page
@immutable
class PageLayoutData {
  const PageLayoutData({
    required this.items,
    this.icons = const [],
    this.textBlock,
  });

  /// All items (photos and maps) with their positions
  final List<ItemLayoutData> items;

  /// Decorative icons with their positions
  final List<IconLayoutData> icons;

  /// Text block position (nullable - no text if null)
  final TextBlockLayout? textBlock;

  /// Copy with modified fields
  PageLayoutData copyWith({
    List<ItemLayoutData>? items,
    List<IconLayoutData>? icons,
    TextBlockLayout? textBlock,
  }) {
    return PageLayoutData(
      items: items ?? this.items,
      icons: icons ?? this.icons,
      textBlock: textBlock ?? this.textBlock,
    );
  }

  /// Get all items sorted by z-index (for rendering order)
  List<ItemLayoutData> get itemsByZIndex {
    final sorted = List<ItemLayoutData>.from(items);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }

  /// Get all icons sorted by z-index (for rendering order)
  List<IconLayoutData> get iconsByZIndex {
    final sorted = List<IconLayoutData>.from(icons);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLayoutData &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          listEquals(icons, other.icons) &&
          textBlock == other.textBlock;

  @override
  int get hashCode =>
      Object.hashAll(items) ^ Object.hashAll(icons) ^ textBlock.hashCode;

  @override
  String toString() =>
      'PageLayoutData(items: ${items.length}, icons: ${icons.length}, hasText: ${textBlock != null})';
}
