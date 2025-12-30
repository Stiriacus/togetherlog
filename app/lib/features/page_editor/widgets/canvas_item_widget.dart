// TogetherLog - Canvas Item Widget
// Renders a single canvas item (photo, decoration, text) with selection handles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bounding_box/bounding_box.dart';
import '../models/canvas_item.dart';
import '../providers/editor_state_provider.dart';

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
  BoundingBoxController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) {
      _initController();
    }
  }

  @override
  void didUpdateWidget(CanvasItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _initController();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _disposeController();
    } else if (widget.isSelected && _controller != null) {
      // Update controller from state changes
      _controller!.update(
        newPosition: widget.item.position,
        newSize: widget.item.size,
        newRotation: widget.item.rotation * (3.14159265359 / 180),
      );
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _initController() {
    _controller = BoundingBoxController(
      position: widget.item.position,
      size: widget.item.size,
      rotation: widget.item.rotation * (3.14159265359 / 180),
      enable: true,
      enableRotate: false, // Disable rotation handle - use properties panel only
    );

    // Listen for position and size changes only
    _controller!.addListener(_onControllerChanged);
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_onControllerChanged);
      // Don't dispose here - BoundingBoxOverlay will dispose it when unmounting
      _controller = null;
    }
  }

  void _onControllerChanged() {
    // Guard against disposed controller
    if (_controller == null || !mounted) return;

    final position = _controller!.position;
    final size = _controller!.size;

    // Delay state updates to avoid modifying provider during build phase
    Future.microtask(() {
      if (!mounted) return;
      ref.read(editorStateProvider(widget.entryId).notifier).updateItemPosition(widget.item.id, position);
      ref.read(editorStateProvider(widget.entryId).notifier).updateItemSize(widget.item.id, size);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.item.isVisible) {
      return const SizedBox.shrink();
    }

    if (!widget.isSelected) {
      // Not selected: just show content at position
      return Positioned(
        left: widget.item.position.dx,
        top: widget.item.position.dy,
        child: GestureDetector(
          onTap: () {
            ref.read(editorStateProvider(widget.entryId).notifier).selectItem(widget.item.id);
          },
          child: Transform.rotate(
            angle: widget.item.rotation * (3.14159265359 / 180),
            child: _buildItemContent(),
          ),
        ),
      );
    }

    // Selected: wrap with BoundingBoxOverlay for drag/resize/rotate
    return BoundingBoxOverlay(
      controller: _controller!,
      builder: (size, position, rotation) {
        return _buildItemContent();
      },
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
}
