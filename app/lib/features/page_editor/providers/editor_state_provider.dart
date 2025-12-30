// TogetherLog - Editor State Provider
// Manages the state and operations of the page editor using Riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/canvas_item.dart';
import '../models/editor_state.dart';

/// Editor state notifier
class EditorStateNotifier extends StateNotifier<EditorState> {
  EditorStateNotifier(String entryId)
      : super(EditorState(entryId: entryId));

  /// Initialize with existing layout
  void initialize(EditorState initialState) {
    state = initialState;
  }

  /// Add item to canvas
  void addItem(CanvasItem item) {
    state = state.copyWith(
      items: [...state.items, item],
      selectedItemId: item.id,
      isDirty: true,
    );
  }

  /// Remove item from canvas
  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
      isDirty: true,
      clearSelection: state.selectedItemId == itemId,
    );
  }

  /// Update specific item
  void updateItem(String itemId, CanvasItem updated) {
    final index = state.items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final newItems = List<CanvasItem>.from(state.items);
    newItems[index] = updated;

    state = state.copyWith(
      items: newItems,
      isDirty: true,
    );
  }

  /// Update item position (for dragging)
  void updateItemPosition(String itemId, Offset newPosition) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    updateItem(itemId, item.copyWith(position: newPosition));
  }

  /// Update item size (for resizing)
  void updateItemSize(String itemId, Size newSize) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    updateItem(itemId, item.copyWith(size: newSize));
  }

  /// Update item rotation (for rotating)
  void updateItemRotation(String itemId, double newRotation) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    // Keep rotation in -180 to +180 range
    updateItem(itemId, item.copyWith(rotation: newRotation.clamp(-180.0, 180.0)));
  }

  /// Update item z-index
  void updateItemZIndex(String itemId, int newZIndex) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    updateItem(itemId, item.copyWith(zIndex: newZIndex));
  }

  /// Toggle item visibility
  void toggleItemVisibility(String itemId) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    final newVisibility = !item.isVisible;
    updateItem(itemId, item.copyWith(isVisible: newVisibility));

    // Deselect item if it's being hidden and is currently selected
    if (!newVisibility && state.selectedItemId == itemId) {
      deselectItem();
    }
  }

  /// Update item text (for text items)
  void updateItemText(String itemId, String newText) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    updateItem(itemId, item.copyWith(text: newText));
  }

  /// Bring item forward (increase z-index by 1)
  void bringItemForward(String itemId) {
    final sortedItems = state.itemsSortedByZIndexDescending;
    final currentIndex = sortedItems.indexWhere((item) => item.id == itemId);

    if (currentIndex <= 0) return; // Already at front

    // Swap with item above (lower index = higher z-index)
    final newIndex = currentIndex - 1;
    _reorderItemsInternal(currentIndex, newIndex, adjustForReorderable: false);
  }

  /// Send item backward (decrease z-index by 1)
  void sendItemBackward(String itemId) {
    final sortedItems = state.itemsSortedByZIndexDescending;
    final currentIndex = sortedItems.indexWhere((item) => item.id == itemId);

    if (currentIndex == -1 || currentIndex >= sortedItems.length - 1) return; // Already at back

    // Swap with item below (higher index = lower z-index)
    final newIndex = currentIndex + 1;
    _reorderItemsInternal(currentIndex, newIndex, adjustForReorderable: false);
  }

  /// Reorder items (for drag-to-reorder in layers panel)
  void reorderItems(int oldIndex, int newIndex) {
    _reorderItemsInternal(oldIndex, newIndex, adjustForReorderable: true);
  }

  /// Internal reorder logic
  void _reorderItemsInternal(int oldIndex, int newIndex, {required bool adjustForReorderable}) {
    final sortedItems = state.itemsSortedByZIndexDescending;

    if (oldIndex < 0 || oldIndex >= sortedItems.length) {
      return;
    }

    // Adjust newIndex according to Flutter's ReorderableListView convention
    if (adjustForReorderable && newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Validate adjusted newIndex
    if (newIndex < 0 || newIndex >= sortedItems.length) {
      return;
    }

    final reorderedItems = List<CanvasItem>.from(sortedItems);
    final item = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, item);

    // Reassign z-index based on new order (highest z = top of list)
    final updatedItems = <CanvasItem>[];
    for (int i = 0; i < reorderedItems.length; i++) {
      updatedItems.add(
        reorderedItems[i].copyWith(zIndex: reorderedItems.length - 1 - i),
      );
    }

    state = state.copyWith(
      items: updatedItems,
      isDirty: true,
    );
  }

  /// Select item
  void selectItem(String? itemId) {
    state = state.copyWith(selectedItemId: itemId);
  }

  /// Deselect current item
  void deselectItem() {
    state = state.copyWith(clearSelection: true);
  }

  /// Update background color
  void updateBackgroundColor(Color color) {
    state = state.copyWith(
      backgroundColor: color,
      isDirty: true,
    );
  }

  /// Mark as saving
  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  /// Set error message
  void setError(String? errorMessage) {
    state = state.copyWith(
      errorMessage: errorMessage,
      clearError: errorMessage == null,
    );
  }

  /// Clear dirty flag (after successful save)
  void markAsSaved() {
    state = state.copyWith(isDirty: false);
  }

  /// Get next available z-index (for new items)
  int getNextZIndex() {
    if (state.items.isEmpty) return 0;
    return state.items.map((item) => item.zIndex).reduce((a, b) => a > b ? a : b) + 1;
  }
}

/// Provider for editor state
final editorStateProvider =
    StateNotifierProvider.family<EditorStateNotifier, EditorState, String>(
  (ref, entryId) => EditorStateNotifier(entryId),
);
