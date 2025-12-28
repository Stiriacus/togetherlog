// TogetherLog - Layers Panel Widget
// Shows all canvas items in z-order with visibility toggles and drag-reorder

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/editor_state_provider.dart';

/// Layers panel showing all canvas items
class LayersPanel extends ConsumerWidget {
  final String entryId;

  const LayersPanel({
    super.key,
    required this.entryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider(entryId));
    final itemsDescending = editorState.itemsSortedByZIndexDescending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Layers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.carbonBlack,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Divider(color: AppColors.divider, height: 1),

        // Layers list
        Expanded(
          child: itemsDescending.isEmpty
              ? Center(
                  child: Text(
                    'No items yet',
                    style: TextStyle(color: AppColors.hintText),
                  ),
                )
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: itemsDescending.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(editorStateProvider(entryId).notifier)
                        .reorderItems(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = itemsDescending[index];
                    final isSelected = item.id == editorState.selectedItemId;
                    // Position from front (index 0 = frontmost)
                    final position = index + 1;

                    return Container(
                      key: ValueKey(item.id),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.oliveWood.withValues(alpha: 0.1)
                            : AppColors.antiqueWhite,
                        borderRadius: BorderRadius.circular(AppRadius.rSm),
                        border: Border.all(
                          color: isSelected ? AppColors.oliveWood : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(editorStateProvider(entryId).notifier)
                                .selectItem(item.id);
                          },
                          borderRadius: BorderRadius.circular(AppRadius.rSm),
                          hoverColor: AppColors.softApricot.withValues(alpha: 0.3),
                          child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Visibility toggle
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(editorStateProvider(entryId).notifier)
                                        .toggleItemVisibility(item.id);
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      item.isVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 18,
                                      color: AppColors.oliveWood,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Position indicator
                              Text(
                                '#$position',
                                style: const TextStyle(
                                  color: AppColors.oliveWood,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Separator
                              Container(
                                width: 1,
                                height: 16,
                                color: AppColors.divider,
                              ),
                              const SizedBox(width: 6),
                              // Item name (stable)
                              Expanded(
                                child: Text(
                                  _getStableItemName(item),
                                  style: const TextStyle(
                                    color: AppColors.carbonBlack,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Up arrow
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(editorStateProvider(entryId).notifier)
                                        .bringItemForward(item.id);
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 18,
                                      color: AppColors.oliveWood,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Down arrow
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(editorStateProvider(entryId).notifier)
                                        .sendItemBackward(item.id);
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 18,
                                      color: AppColors.oliveWood,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Drag handle
                              GestureDetector(
                                onPanDown: (_) {
                                  // Select item when starting to drag
                                  ref
                                      .read(editorStateProvider(entryId).notifier)
                                      .selectItem(item.id);
                                },
                                child: ReorderableDragStartListener(
                                  index: index,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // Select item when clicking drag handle
                                        ref
                                            .read(editorStateProvider(entryId).notifier)
                                            .selectItem(item.id);
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.grab,
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.drag_indicator,
                                            size: 18,
                                            color: AppColors.oliveWood,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getStableItemName(dynamic item) {
    // Extract a stable identifier from the item ID
    // IDs are typically like "photo-1", "decoration-2", etc.
    final id = item.id as String;

    // Try to parse the ID format
    if (id.contains('-')) {
      final parts = id.split('-');
      if (parts.length >= 2) {
        final type = parts[0];
        final number = parts[1];

        switch (type) {
          case 'photo':
            return 'Photo $number';
          case 'decoration':
            return 'Decoration $number';
          case 'text':
            return 'Text $number';
          default:
            return '${_capitalize(type)} $number';
        }
      }
    }

    // Fallback to type name
    final typeName = item.type.name as String;
    return _capitalize(typeName);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
