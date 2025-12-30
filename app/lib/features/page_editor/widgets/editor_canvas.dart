// TogetherLog - Editor Canvas Widget
// Renders the scrapbook page canvas with frame decoration and canvas items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defer_pointer/defer_pointer.dart';
import '../providers/editor_state_provider.dart';
import 'canvas_item_widget.dart';

/// Canvas dimensions (DIN A5 at 150 DPI)
const double kCanvasWidth = 874.0;
const double kCanvasHeight = 1240.0;

/// Content area padding (for frame decoration)
const double kContentPaddingHorizontal = 64.0;
const double kContentPaddingVertical = 48.0;

/// Usable content area (within frame)
const double kContentWidth = kCanvasWidth - (kContentPaddingHorizontal * 2); // 746px
const double kContentHeight = kCanvasHeight - (kContentPaddingVertical * 2); // 1144px

/// Editor canvas widget
class EditorCanvas extends ConsumerWidget {
  final String entryId;
  final VoidCallback? onTextItemDoubleClick;

  const EditorCanvas({
    super.key,
    required this.entryId,
    this.onTextItemDoubleClick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider(entryId));

    return DeferredPointerHandler(
      child: Container(
        width: kCanvasWidth,
        height: kCanvasHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background color with tap to deselect
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Deselect item when tapping canvas background
              ref.read(editorStateProvider(entryId).notifier).deselectItem();
            },
            child: Container(
              color: editorState.backgroundColor,
            ),
          ),

            // Frame decoration (ignores pointer events)
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/decorations/classic_boarder_olivebrown.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Content area (padding for frame)
            Positioned(
              left: kContentPaddingHorizontal,
              top: kContentPaddingVertical,
              child: SizedBox(
                width: kContentWidth,
                height: kContentHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Render all canvas items sorted by z-index (low to high)
                    ...editorState.itemsSortedByZIndex.map((item) {
                      return CanvasItemWidget(
                        key: ValueKey(item.id),
                        item: item,
                        entryId: entryId,
                        isSelected: item.id == editorState.selectedItemId,
                        onTextItemDoubleClick: onTextItemDoubleClick,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Debug content area boundary (optional, comment out for production)
            Positioned(
              left: kContentPaddingHorizontal,
              top: kContentPaddingVertical,
              child: IgnorePointer(
                child: Container(
                  width: kContentWidth,
                  height: kContentHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
