// TogetherLog - Canvas Item Model
// Represents an item (photo, decoration, text) on the scrapbook page canvas

import 'package:flutter/material.dart';

/// Type of canvas item
enum CanvasItemType {
  photo,
  decoration,
  text,
}

/// Represents a single item on the canvas (photo, decoration, or text)
@immutable
class CanvasItem {
  final String id;
  final CanvasItemType type;
  final Offset position; // x, y in pixels (relative to content area)
  final Size size; // width, height in pixels
  final double rotation; // degrees (0-360)
  final int zIndex;
  final bool isVisible;

  // Type-specific data
  final String? photoUrl; // for type=photo
  final String? decorationUrl; // for type=decoration
  final String? text; // for type=text
  final TextStyle? textStyle; // for type=text

  /// Primary constructor
  const CanvasItem({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.rotation = 0,
    required this.zIndex,
    this.isVisible = true,
    this.photoUrl,
    this.decorationUrl,
    this.text,
    this.textStyle,
  });

  /// Creates a photo item
  factory CanvasItem.photo({
    required String id,
    required String photoUrl,
    required Offset position,
    required Size size,
    double rotation = 0,
    required int zIndex,
  }) {
    return CanvasItem(
      id: id,
      type: CanvasItemType.photo,
      position: position,
      size: size,
      rotation: rotation,
      zIndex: zIndex,
      photoUrl: photoUrl,
    );
  }

  /// Creates a decoration item
  factory CanvasItem.decoration({
    required String id,
    required String decorationUrl,
    required Offset position,
    required Size size,
    double rotation = 0,
    required int zIndex,
  }) {
    return CanvasItem(
      id: id,
      type: CanvasItemType.decoration,
      position: position,
      size: size,
      rotation: rotation,
      zIndex: zIndex,
      decorationUrl: decorationUrl,
    );
  }

  /// Creates a text item
  factory CanvasItem.text({
    required String id,
    required String text,
    required Offset position,
    required Size size,
    double rotation = 0,
    required int zIndex,
    TextStyle? textStyle,
  }) {
    return CanvasItem(
      id: id,
      type: CanvasItemType.text,
      position: position,
      size: size,
      rotation: rotation,
      zIndex: zIndex,
      text: text,
      textStyle: textStyle,
    );
  }

  /// Copy with updated fields
  CanvasItem copyWith({
    String? id,
    CanvasItemType? type,
    Offset? position,
    Size? size,
    double? rotation,
    int? zIndex,
    bool? isVisible,
    String? photoUrl,
    String? decorationUrl,
    String? text,
    TextStyle? textStyle,
  }) {
    return CanvasItem(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isVisible: isVisible ?? this.isVisible,
      photoUrl: photoUrl ?? this.photoUrl,
      decorationUrl: decorationUrl ?? this.decorationUrl,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': {'x': position.dx, 'y': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'rotation': rotation,
      'zIndex': zIndex,
      'isVisible': isVisible,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (decorationUrl != null) 'decorationUrl': decorationUrl,
      if (text != null) 'text': text,
      if (textStyle != null)
        'textStyle': {
          'fontSize': textStyle!.fontSize,
          'color': textStyle!.color?.toARGB32(),
          'fontWeight': textStyle!.fontWeight?.index,
        },
    };
  }

  /// Creates from JSON
  factory CanvasItem.fromJson(Map<String, dynamic> json) {
    final type = CanvasItemType.values.firstWhere(
      (e) => e.name == json['type'],
    );

    TextStyle? textStyle;
    if (json['textStyle'] != null) {
      final ts = json['textStyle'] as Map<String, dynamic>;
      textStyle = TextStyle(
        fontSize: ts['fontSize'] as double?,
        color: ts['color'] != null ? Color(ts['color'] as int) : null,
        fontWeight: ts['fontWeight'] != null
            ? FontWeight.values[ts['fontWeight'] as int]
            : null,
      );
    }

    return CanvasItem(
      id: json['id'] as String,
      type: type,
      position: Offset(
        json['position']['x'] as double,
        json['position']['y'] as double,
      ),
      size: Size(
        json['size']['width'] as double,
        json['size']['height'] as double,
      ),
      rotation: json['rotation'] as double,
      zIndex: json['zIndex'] as int,
      isVisible: json['isVisible'] as bool? ?? true,
      photoUrl: json['photoUrl'] as String?,
      decorationUrl: json['decorationUrl'] as String?,
      text: json['text'] as String?,
      textStyle: textStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
