// TogetherLog - Editor State Model
// Manages the state of the page editor including all canvas items

import 'package:flutter/material.dart';
import 'canvas_item.dart';

/// Represents the complete state of the page editor
@immutable
class EditorState {
  final String entryId;
  final List<CanvasItem> items;
  final String? selectedItemId;
  final Color backgroundColor;
  final bool isDirty; // Has unsaved changes
  final bool isSaving;
  final String? errorMessage;

  /// Primary constructor
  const EditorState({
    required this.entryId,
    this.items = const [],
    this.selectedItemId,
    this.backgroundColor = const Color(0xFFE0E0E0), // Default neutral
    this.isDirty = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Creates from JSON (custom_layout field)
  factory EditorState.fromJson(String entryId, Map<String, dynamic> json) {
    Color bgColor = const Color(0xFFE0E0E0);
    if (json['backgroundColor'] != null) {
      final colorString = json['backgroundColor'] as String;
      if (colorString.startsWith('#')) {
        bgColor = Color(int.parse('FF${colorString.substring(1)}', radix: 16));
      }
    }

    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((itemJson) => CanvasItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return EditorState(
      entryId: entryId,
      items: items,
      backgroundColor: bgColor,
    );
  }

  /// Get selected item
  CanvasItem? get selectedItem {
    if (selectedItemId == null) return null;
    try {
      return items.firstWhere((item) => item.id == selectedItemId);
    } catch (_) {
      return null;
    }
  }

  /// Get items sorted by z-index (low to high for rendering)
  List<CanvasItem> get itemsSortedByZIndex {
    final sorted = List<CanvasItem>.from(items);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }

  /// Get items sorted by z-index (high to low for layers panel)
  List<CanvasItem> get itemsSortedByZIndexDescending {
    final sorted = List<CanvasItem>.from(items);
    sorted.sort((a, b) => b.zIndex.compareTo(a.zIndex));
    return sorted;
  }

  /// Copy with updated fields
  EditorState copyWith({
    String? entryId,
    List<CanvasItem>? items,
    String? selectedItemId,
    Color? backgroundColor,
    bool? isDirty,
    bool? isSaving,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return EditorState(
      entryId: entryId ?? this.entryId,
      items: items ?? this.items,
      selectedItemId: clearSelection ? null : (selectedItemId ?? this.selectedItemId),
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Converts to JSON for storage (custom_layout field)
  Map<String, dynamic> toJson() {
    return {
      'version': '1.0',
      'backgroundColor': '#${backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorState &&
          runtimeType == other.runtimeType &&
          entryId == other.entryId &&
          selectedItemId == other.selectedItemId &&
          backgroundColor == other.backgroundColor &&
          isDirty == other.isDirty &&
          isSaving == other.isSaving;

  @override
  int get hashCode =>
      entryId.hashCode ^
      selectedItemId.hashCode ^
      backgroundColor.hashCode ^
      isDirty.hashCode ^
      isSaving.hashCode;
}
