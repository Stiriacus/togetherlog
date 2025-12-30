// TogetherLog - Right Gutter Panel
// Properties panel for selected items (Rotation, Size, Position, Opacity)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/editor_state_provider.dart';

/// Right gutter panel for item properties
class RightGutterPanel extends ConsumerStatefulWidget {
  const RightGutterPanel({
    super.key,
    required this.entryId,
    required this.isExpanded,
    required this.onToggle,
  });

  final String entryId;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  ConsumerState<RightGutterPanel> createState() => _RightGutterPanelState();
}

class _RightGutterPanelState extends ConsumerState<RightGutterPanel> {
  bool _isRotationExpanded = true;
  bool _isSizeExpanded = false;
  bool _isPositionExpanded = false;
  bool _isAppearanceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorStateProvider(widget.entryId));
    final hasSelection = editorState.selectedItemId != null;

    // Collapsed state - show icon-only tab
    if (!widget.isExpanded) {
      return Column(
        children: [
          // Toggle button
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.darkWalnut),
            onPressed: widget.onToggle,
            tooltip: 'Expand Properties',
          ),
          Divider(color: AppColors.divider, height: 1),
          // Vertical icons
          if (hasSelection) ...[
            _buildCollapsedIcon(Icons.rotate_right, 'Rotation'),
            _buildCollapsedIcon(Icons.aspect_ratio, 'Size'),
            _buildCollapsedIcon(Icons.open_with, 'Position'),
            _buildCollapsedIcon(Icons.opacity, 'Appearance'),
          ],
        ],
      );
    }

    // Expanded state - full panel
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with collapse button
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Properties',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.carbonBlack,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.darkWalnut, size: 20),
                onPressed: widget.onToggle,
                tooltip: 'Collapse Properties',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Divider(color: AppColors.divider, height: 1),

        // Content
        Expanded(
          child: hasSelection
              ? _buildPropertiesContent(editorState)
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildCollapsedIcon(IconData icon, String tooltip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: IconButton(
        icon: Icon(icon, color: AppColors.darkWalnut, size: 24),
        onPressed: () {
          // TODO: Could expand panel and open that section
        },
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Select an item to edit its properties',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPropertiesContent(dynamic editorState) {
    final selectedItem = editorState.items.firstWhere(
      (item) => item.id == editorState.selectedItemId,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Rotation Section
          _buildCollapsibleSection(
            title: 'Rotation',
            icon: Icons.rotate_right,
            isExpanded: _isRotationExpanded,
            onToggle: () {
              setState(() {
                _isRotationExpanded = !_isRotationExpanded;
              });
            },
            child: _RotationControls(
              key: ValueKey('rotation_${editorState.selectedItemId}'),
              entryId: widget.entryId,
              itemId: editorState.selectedItemId as String,
              currentRotation: selectedItem.rotation as double,
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // Size Section
          _buildCollapsibleSection(
            title: 'Size',
            icon: Icons.aspect_ratio,
            isExpanded: _isSizeExpanded,
            onToggle: () {
              setState(() {
                _isSizeExpanded = !_isSizeExpanded;
              });
            },
            child: _SizeControls(
              entryId: widget.entryId,
              itemId: editorState.selectedItemId as String,
              currentSize: selectedItem.size as Size,
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // Position Section
          _buildCollapsibleSection(
            title: 'Position',
            icon: Icons.open_with,
            isExpanded: _isPositionExpanded,
            onToggle: () {
              setState(() {
                _isPositionExpanded = !_isPositionExpanded;
              });
            },
            child: _PositionControls(
              entryId: widget.entryId,
              itemId: editorState.selectedItemId as String,
              currentPosition: selectedItem.position as Offset,
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // Appearance Section
          _buildCollapsibleSection(
            title: 'Appearance',
            icon: Icons.opacity,
            isExpanded: _isAppearanceExpanded,
            onToggle: () {
              setState(() {
                _isAppearanceExpanded = !_isAppearanceExpanded;
              });
            },
            child: _AppearanceControls(
              entryId: widget.entryId,
              itemId: editorState.selectedItemId as String,
              isVisible: selectedItem.isVisible as bool,
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // Delete Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(editorStateProvider(widget.entryId).notifier)
                      .removeItem(editorState.selectedItemId as String);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete Item',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.darkWalnut,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.carbonBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: AppColors.darkWalnut,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) child,
      ],
    );
  }
}

// Rotation Controls Widget
class _RotationControls extends ConsumerStatefulWidget {
  const _RotationControls({
    super.key,
    required this.entryId,
    required this.itemId,
    required this.currentRotation,
  });

  final String entryId;
  final String itemId;
  final double currentRotation;

  @override
  ConsumerState<_RotationControls> createState() => _RotationControlsState();
}

class _RotationControlsState extends ConsumerState<_RotationControls> {
  late TextEditingController _textController;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentRotation;
    _textController = TextEditingController(text: widget.currentRotation.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_RotationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRotation != oldWidget.currentRotation) {
      _sliderValue = widget.currentRotation;
      _textController.text = widget.currentRotation.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateRotation(double newRotation) {
    ref.read(editorStateProvider(widget.entryId).notifier)
       .updateItemRotation(widget.itemId, newRotation);
  }

  void _resetRotation() {
    _updateRotation(0.0);
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
    _updateRotation(value);
  }

  void _onTextSubmitted(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      _updateRotation(parsed.clamp(-180.0, 180.0));
    } else {
      _textController.text = widget.currentRotation.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider with value display
          Row(
            children: [
              const Text(
                '-180°',
                style: TextStyle(fontSize: 11, color: AppColors.oliveWood),
              ),
              Expanded(
                child: Slider(
                  value: _sliderValue.clamp(-180.0, 180.0),
                  min: -180,
                  max: 180,
                  divisions: 360,
                  label: '${_sliderValue.toStringAsFixed(0)}°',
                  activeColor: AppColors.darkWalnut,
                  onChanged: _onSliderChanged,
                ),
              ),
              const Text(
                '+180°',
                style: TextStyle(fontSize: 11, color: AppColors.oliveWood),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Current rotation value
          Center(
            child: Text(
              '${widget.currentRotation.toStringAsFixed(1)}°',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkWalnut,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Quick rotation buttons
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _buildRotationButton(label: '-90°', onPressed: () => _updateRotation(-90)),
              _buildRotationButton(label: '-45°', onPressed: () => _updateRotation(-45)),
              _buildRotationButton(label: '0°', onPressed: _resetRotation, isPrimary: true),
              _buildRotationButton(label: '+45°', onPressed: () => _updateRotation(45)),
              _buildRotationButton(label: '+90°', onPressed: () => _updateRotation(90)),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Precise input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Precise:',
                style: TextStyle(fontSize: 12, color: AppColors.darkWalnut),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.oliveWood),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.oliveWood),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkWalnut, width: 2),
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.darkWalnut),
                  textAlign: TextAlign.center,
                  onSubmitted: _onTextSubmitted,
                ),
              ),
              const SizedBox(width: 2),
              const Text('°', style: TextStyle(fontSize: 12, color: AppColors.darkWalnut)),
              const SizedBox(width: AppSpacing.xs),
              Column(
                children: [
                  SizedBox(
                    width: 28,
                    height: 22,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_drop_up, size: 18, color: AppColors.darkWalnut),
                      onPressed: () => _updateRotation((widget.currentRotation + 1).clamp(-180.0, 180.0)),
                      tooltip: '+1°',
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: 22,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.darkWalnut),
                      onPressed: () => _updateRotation((widget.currentRotation - 1).clamp(-180.0, 180.0)),
                      tooltip: '-1°',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRotationButton({
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: 58,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          minimumSize: const Size(0, 0),
          side: BorderSide(
            color: isPrimary
                ? AppColors.darkWalnut
                : AppColors.oliveWood.withValues(alpha: 0.3),
          ),
          backgroundColor: isPrimary ? AppColors.darkWalnut.withValues(alpha: 0.1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.darkWalnut,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Size Controls Widget (Placeholder)
class _SizeControls extends StatelessWidget {
  const _SizeControls({
    required this.entryId,
    required this.itemId,
    required this.currentSize,
  });

  final String entryId;
  final String itemId;
  final Size currentSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Text(
            'Width: ${currentSize.width.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 13, color: AppColors.carbonBlack),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Height: ${currentSize.height.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 13, color: AppColors.carbonBlack),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Size controls coming soon',
            style: TextStyle(fontSize: 12, color: AppColors.hintText),
          ),
        ],
      ),
    );
  }
}

// Position Controls Widget (Placeholder)
class _PositionControls extends StatelessWidget {
  const _PositionControls({
    required this.entryId,
    required this.itemId,
    required this.currentPosition,
  });

  final String entryId;
  final String itemId;
  final Offset currentPosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Text(
            'X: ${currentPosition.dx.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 13, color: AppColors.carbonBlack),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Y: ${currentPosition.dy.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 13, color: AppColors.carbonBlack),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Position controls coming soon',
            style: TextStyle(fontSize: 12, color: AppColors.hintText),
          ),
        ],
      ),
    );
  }
}

// Appearance Controls Widget (Placeholder)
class _AppearanceControls extends ConsumerWidget {
  const _AppearanceControls({
    required this.entryId,
    required this.itemId,
    required this.isVisible,
  });

  final String entryId;
  final String itemId;
  final bool isVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visibility:',
                style: TextStyle(fontSize: 13, color: AppColors.carbonBlack),
              ),
              Switch(
                value: isVisible,
                onChanged: (value) {
                  ref
                      .read(editorStateProvider(entryId).notifier)
                      .toggleItemVisibility(itemId);
                },
                activeColor: AppColors.darkWalnut,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Opacity controls coming soon',
            style: TextStyle(fontSize: 12, color: AppColors.hintText),
          ),
        ],
      ),
    );
  }
}
