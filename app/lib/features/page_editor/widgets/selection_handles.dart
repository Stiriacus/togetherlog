// TogetherLog - Selection Handles Widget
// Shows resize, rotate, and delete handles for selected canvas items

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'dart:math' as math;
import '../models/canvas_item.dart';
import '../providers/editor_state_provider.dart';

/// Selection handles for resize, rotate, and delete operations
class SelectionHandles extends ConsumerStatefulWidget {
  final CanvasItem item;
  final String entryId;
  final VoidCallback? onEditText;
  final ValueChanged<double?>? onRotationPreview;

  const SelectionHandles({
    super.key,
    required this.item,
    required this.entryId,
    this.onEditText,
    this.onRotationPreview,
  });

  @override
  ConsumerState<SelectionHandles> createState() => _SelectionHandlesState();
}

class _SelectionHandlesState extends ConsumerState<SelectionHandles> {
  Size? _resizeSize;
  double? _rotateAngle;

  @override
  Widget build(BuildContext context) {
    final size = _resizeSize ?? widget.item.size;

    // Add padding for buttons that extend outside the item bounds
    const buttonOverhang = 50.0; // Space for buttons outside bounds

    return DeferPointer(
      child: Container(
        width: size.width + (buttonOverhang * 2),
        height: size.height + (buttonOverhang * 2),
        transform: Matrix4.translationValues(-buttonOverhang, -buttonOverhang, 0),
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection border (ignores pointer, positioned to match actual content)
            Positioned(
              left: buttonOverhang,
              top: buttonOverhang,
              child: IgnorePointer(
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),

            // Resize handles (4 corners) - offset by buttonOverhang
            ..._buildResizeHandles(buttonOverhang),

            // Rotation handle (top center) - offset by buttonOverhang
            _buildRotationHandle(buttonOverhang),

            // Layer controls (bottom right) - offset by buttonOverhang
            _buildLayerControls(buttonOverhang),

            // Delete button (top left) - offset by buttonOverhang
            _buildDeleteButton(buttonOverhang),

            // Edit button (top right, for text items) - offset by buttonOverhang
            if (widget.onEditText != null) _buildEditButton(buttonOverhang),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles(double overhang) {
    const handleSize = 16.0;
    final size = _resizeSize ?? widget.item.size;

    return [
      // Top-left
      _buildResizeHandle(
        left: overhang - handleSize / 2,
        top: overhang - handleSize / 2,
        cursor: SystemMouseCursors.resizeUpLeft,
        onPan: (delta) => _handleResize(delta, isTopLeft: true),
      ),
      // Top-right
      _buildResizeHandle(
        left: overhang + size.width - handleSize / 2,
        top: overhang - handleSize / 2,
        cursor: SystemMouseCursors.resizeUpRight,
        onPan: (delta) => _handleResize(delta, isTopRight: true),
      ),
      // Bottom-left
      _buildResizeHandle(
        left: overhang - handleSize / 2,
        top: overhang + size.height - handleSize / 2,
        cursor: SystemMouseCursors.resizeDownLeft,
        onPan: (delta) => _handleResize(delta, isBottomLeft: true),
      ),
      // Bottom-right
      _buildResizeHandle(
        left: overhang + size.width - handleSize / 2,
        top: overhang + size.height - handleSize / 2,
        cursor: SystemMouseCursors.resizeDownRight,
        onPan: (delta) => _handleResize(delta, isBottomRight: true),
      ),
    ];
  }

  Widget _buildResizeHandle({
    required double left,
    required double top,
    required SystemMouseCursor cursor,
    required Function(Offset) onPan,
  }) {
    const handleSize = 16.0;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          // Ensure this handle gets the gesture
        },
        onPanUpdate: (details) => onPan(details.delta),
        onPanEnd: (_) {
          if (_resizeSize != null) {
            ref
                .read(editorStateProvider(widget.entryId).notifier)
                .updateItemSize(widget.item.id, _resizeSize!);
            setState(() => _resizeSize = null);
          }
        },
        child: MouseRegion(
          cursor: cursor,
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle(double overhang) {
    const handleSize = 24.0;
    final size = _resizeSize ?? widget.item.size;

    return Positioned(
      left: overhang + (size.width - handleSize) / 2,
      top: overhang - 40,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          // Ensure this handle gets the gesture
        },
        onPanUpdate: (details) {
          final center = Offset(
            widget.item.size.width / 2,
            widget.item.size.height / 2,
          );
          final angle = math.atan2(
            details.localPosition.dy - center.dy - 40,
            details.localPosition.dx - center.dx,
          );
          final newRotation = (angle * 180 / math.pi) + 90;
          setState(() {
            _rotateAngle = newRotation;
          });
          // Notify parent for live preview
          widget.onRotationPreview?.call(newRotation);
        },
        onPanEnd: (_) {
          if (_rotateAngle != null) {
            ref
                .read(editorStateProvider(widget.entryId).notifier)
                .updateItemRotation(widget.item.id, _rotateAngle!);
            setState(() => _rotateAngle = null);
          }
          // Clear preview
          widget.onRotationPreview?.call(null);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rotate_right,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(double overhang) {
    const buttonSize = 24.0;

    return Positioned(
      left: overhang - 12,
      top: overhang - 12,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ref
                .read(editorStateProvider(widget.entryId).notifier)
                .removeItem(widget.item.id);
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(double overhang) {
    const buttonSize = 24.0;
    final size = _resizeSize ?? widget.item.size;

    return Positioned(
      left: overhang + size.width - 12,
      top: overhang - 12,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onEditText,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerControls(double overhang) {
    final size = _resizeSize ?? widget.item.size;

    return Positioned(
      left: overhang + size.width + 8,
      top: overhang + size.height - 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bring forward
          _buildLayerButton(
            icon: Icons.arrow_upward,
            onTap: () {
              ref
                  .read(editorStateProvider(widget.entryId).notifier)
                  .bringItemForward(widget.item.id);
            },
            tooltip: 'Bring forward',
          ),
          const SizedBox(height: 4),
          // Send backward
          _buildLayerButton(
            icon: Icons.arrow_downward,
            onTap: () {
              ref
                  .read(editorStateProvider(widget.entryId).notifier)
                  .sendItemBackward(widget.item.id);
            },
            tooltip: 'Send backward',
          ),
        ],
      ),
    );
  }

  Widget _buildLayerButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleResize(
    Offset delta, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    final currentSize = _resizeSize ?? widget.item.size;

    // Calculate size delta based on which corner is being dragged
    double widthDelta = 0;
    double heightDelta = 0;

    if (isTopLeft || isBottomLeft) {
      widthDelta = -delta.dx; // Inverse for left handles
    } else {
      widthDelta = delta.dx;
    }

    if (isTopLeft || isTopRight) {
      heightDelta = -delta.dy; // Inverse for top handles
    } else {
      heightDelta = delta.dy;
    }

    // Maintain aspect ratio
    final aspectRatio = currentSize.width / currentSize.height;
    final avgDelta = (widthDelta + heightDelta * aspectRatio) / 2;

    double newWidth = currentSize.width + avgDelta;
    double newHeight = newWidth / aspectRatio;

    // Enforce min/max constraints
    newWidth = newWidth.clamp(80.0, 600.0);
    newHeight = newHeight.clamp(80.0, 600.0);

    setState(() {
      _resizeSize = Size(newWidth, newHeight);
    });
  }
}
