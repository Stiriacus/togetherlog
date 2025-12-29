// TogetherLog - Canvas Item Widget
// Renders a single canvas item (photo, decoration, text) with selection handles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/canvas_item.dart';
import '../providers/editor_state_provider.dart';
import 'selection_handles.dart';

/// Renders a canvas item with drag-drop, resize, rotate support
class CanvasItemWidget extends ConsumerStatefulWidget {
  final CanvasItem item;
  final String entryId;
  final bool isSelected;

  const CanvasItemWidget({
    super.key,
    required this.item,
    required this.entryId,
    required this.isSelected,
  });

  @override
  ConsumerState<CanvasItemWidget> createState() => _CanvasItemWidgetState();
}

class _CanvasItemWidgetState extends ConsumerState<CanvasItemWidget> {
  Offset? _dragStart;
  Offset? _dragOffset;
  bool _isDragging = false;
  double? _previewRotation;

  @override
  Widget build(BuildContext context) {
    if (!widget.item.isVisible) {
      return const SizedBox.shrink();
    }

    final effectivePosition = _dragOffset ?? widget.item.position;
    final effectiveRotation = _previewRotation ?? widget.item.rotation;

    return Positioned(
      left: effectivePosition.dx,
      top: effectivePosition.dy,
      child: SizedBox(
        width: widget.item.size.width,
        height: widget.item.size.height,
        child: Transform.rotate(
          angle: effectiveRotation * (3.14159265359 / 180), // degrees to radians
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Item content with drag and double-click
              MouseRegion(
                cursor: widget.isSelected ? SystemMouseCursors.move : SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // Select this item
                    ref
                        .read(editorStateProvider(widget.entryId).notifier)
                        .selectItem(widget.item.id);
                  },
                  onDoubleTap: widget.item.type == CanvasItemType.text
                      ? () => _showTextEditor(context)
                      : null,
                  onPanStart: (details) {
                    if (widget.isSelected) {
                      setState(() {
                        _isDragging = true;
                        _dragStart = details.globalPosition - widget.item.position;
                      });
                    }
                  },
                  onPanUpdate: (details) {
                    if (widget.isSelected && _isDragging) {
                      setState(() {
                        _dragOffset = details.globalPosition - _dragStart!;
                      });
                    }
                  },
                  onPanEnd: (details) {
                    if (widget.isSelected && _isDragging && _dragOffset != null) {
                      // Update item position in state
                      ref
                          .read(editorStateProvider(widget.entryId).notifier)
                          .updateItemPosition(widget.item.id, _dragOffset!);
                    }
                    setState(() {
                      _dragOffset = null;
                      _dragStart = null;
                      _isDragging = false;
                    });
                  },
                  child: _buildItemContent(),
                ),
              ),

              // Selection handles (if selected)
              if (widget.isSelected)
                SelectionHandles(
                  item: widget.item,
                  entryId: widget.entryId,
                  onEditText: widget.item.type == CanvasItemType.text
                      ? () => _showTextEditor(context)
                      : null,
                  onRotationPreview: (rotation) {
                    setState(() {
                      _previewRotation = rotation;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent() {
    switch (widget.item.type) {
      case CanvasItemType.photo:
        return _buildPhoto();
      case CanvasItemType.decoration:
        return _buildDecoration();
      case CanvasItemType.text:
        return _buildText();
    }
  }

  Widget _buildPhoto() {
    return Container(
      width: widget.item.size.width,
      height: widget.item.size.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.item.photoUrl != null
          ? Image.network(
              widget.item.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 48),
                );
              },
            )
          : const Center(
              child: Icon(Icons.photo, size: 48),
            ),
    );
  }

  Widget _buildDecoration() {
    return SizedBox(
      width: widget.item.size.width,
      height: widget.item.size.height,
      child: widget.item.decorationUrl != null
          ? Image.network(
              widget.item.decorationUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, size: 48),
                );
              },
            )
          : const Center(
              child: Icon(Icons.image, size: 48),
            ),
    );
  }

  Widget _buildText() {
    return Container(
      width: widget.item.size.width,
      height: widget.item.size.height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        widget.item.text ?? '',
        style: widget.item.textStyle ?? const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showTextEditor(BuildContext context) {
    final textController = TextEditingController(text: widget.item.text ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(editorStateProvider(widget.entryId).notifier)
                  .updateItemText(widget.item.id, textController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
