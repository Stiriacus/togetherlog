// TogetherLog - Left Gutter Panel
// Tool and asset selection panel (Photos, Decorations, Background, Layers)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/editor_state_provider.dart';

/// Left gutter panel for tool and asset selection
class LeftGutterPanel extends ConsumerStatefulWidget {
  const LeftGutterPanel({
    super.key,
    required this.entryId,
    required this.isExpanded,
    required this.onToggle,
  });

  final String entryId;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  ConsumerState<LeftGutterPanel> createState() => _LeftGutterPanelState();
}

class _LeftGutterPanelState extends ConsumerState<LeftGutterPanel> {
  bool _isPhotosExpanded = false;
  bool _isDecorationsExpanded = false;
  bool _isBackgroundExpanded = false;
  bool _isLayersExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Collapsed state - show icon-only tab
    if (!widget.isExpanded) {
      return Column(
        children: [
          // Toggle button
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.darkWalnut),
            onPressed: widget.onToggle,
            tooltip: 'Expand Tools',
          ),
          Divider(color: AppColors.divider, height: 1),
          // Vertical icons
          Expanded(
            child: Column(
              children: [
                _buildCollapsedIcon(Icons.photo_library, 'Photos', () {
                  setState(() => _isPhotosExpanded = true);
                }),
                _buildCollapsedIcon(Icons.image, 'Decorations', () {
                  setState(() => _isDecorationsExpanded = true);
                }),
                _buildCollapsedIcon(Icons.palette, 'Background', () {
                  setState(() => _isBackgroundExpanded = true);
                }),
                _buildCollapsedIcon(Icons.layers, 'Layers', () {
                  setState(() => _isLayersExpanded = true);
                }),
              ],
            ),
          ),
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
                  'Tools',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.carbonBlack,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.darkWalnut, size: 20),
                onPressed: widget.onToggle,
                tooltip: 'Collapse Tools',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Divider(color: AppColors.divider, height: 1),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                  // Photos Section
                  _buildCollapsibleSection(
                    title: 'Photos',
                    icon: Icons.photo_library,
                    isExpanded: _isPhotosExpanded,
                    onToggle: () {
                      setState(() {
                        _isPhotosExpanded = !_isPhotosExpanded;
                      });
                    },
                    child: _buildPhotosContent(),
                  ),

                  Divider(color: AppColors.divider, height: 1),

                  // Decorations Section
                  _buildCollapsibleSection(
                    title: 'Decorations',
                    icon: Icons.image,
                    isExpanded: _isDecorationsExpanded,
                    onToggle: () {
                      setState(() {
                        _isDecorationsExpanded = !_isDecorationsExpanded;
                      });
                    },
                    child: _buildDecorationsContent(),
                  ),

                  Divider(color: AppColors.divider, height: 1),

                  // Background Section
                  _buildCollapsibleSection(
                    title: 'Background',
                    icon: Icons.palette,
                    isExpanded: _isBackgroundExpanded,
                    onToggle: () {
                      setState(() {
                        _isBackgroundExpanded = !_isBackgroundExpanded;
                      });
                    },
                    child: _buildBackgroundContent(),
                  ),

                  Divider(color: AppColors.divider, height: 1),

                  // Layers Section
                  _buildCollapsibleSection(
                    title: 'Layers',
                    icon: Icons.layers,
                    isExpanded: _isLayersExpanded,
                    onToggle: () {
                      setState(() {
                        _isLayersExpanded = !_isLayersExpanded;
                      });
                    },
                    child: _buildLayersContent(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedIcon(IconData icon, String tooltip, VoidCallback onExpand) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: IconButton(
        icon: Icon(icon, color: AppColors.darkWalnut, size: 24),
        onPressed: () {
          widget.onToggle(); // Expand the gutter
          onExpand(); // Open the specific section
        },
        tooltip: tooltip,
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

  Widget _buildPhotosContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Center(
        child: Text(
          'Photo picker coming soon',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationsContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Center(
        child: Text(
          'Decoration picker coming soon',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Center(
        child: Text(
          'Background color picker coming soon',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLayersContent() {
    final editorState = ref.watch(editorStateProvider(widget.entryId));
    final itemsDescending = editorState.itemsSortedByZIndexDescending;

    if (itemsDescending.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Text(
            'No items yet',
            style: TextStyle(color: AppColors.hintText, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemCount: itemsDescending.length,
        onReorder: (oldIndex, newIndex) {
          ref
              .read(editorStateProvider(widget.entryId).notifier)
              .reorderItems(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final item = itemsDescending[index];
          final isSelected = item.id == editorState.selectedItemId;
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
                      .read(editorStateProvider(widget.entryId).notifier)
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
                    children: [
                      // Visibility toggle
                      _buildIconButton(
                        icon: item.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onTap: () {
                          ref
                              .read(editorStateProvider(widget.entryId).notifier)
                              .toggleItemVisibility(item.id);
                        },
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
                      // Item name
                      Expanded(
                        child: Text(
                          _getItemName(item),
                          style: const TextStyle(
                            color: AppColors.carbonBlack,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Up arrow
                      _buildIconButton(
                        icon: Icons.arrow_upward,
                        onTap: () {
                          ref
                              .read(editorStateProvider(widget.entryId).notifier)
                              .bringItemForward(item.id);
                        },
                      ),
                      const SizedBox(width: 2),
                      // Down arrow
                      _buildIconButton(
                        icon: Icons.arrow_downward,
                        onTap: () {
                          ref
                              .read(editorStateProvider(widget.entryId).notifier)
                              .sendItemBackward(item.id);
                        },
                      ),
                      const SizedBox(width: 2),
                      // Drag handle
                      GestureDetector(
                        onPanDown: (_) {
                          ref
                              .read(editorStateProvider(widget.entryId).notifier)
                              .selectItem(item.id);
                        },
                        child: ReorderableDragStartListener(
                          index: index,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ref
                                    .read(editorStateProvider(widget.entryId).notifier)
                                    .selectItem(item.id);
                              },
                              borderRadius: BorderRadius.circular(4),
                              hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
                              child: const MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: Padding(
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
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppColors.darkWalnut.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.oliveWood,
          ),
        ),
      ),
    );
  }

  String _getItemName(dynamic item) {
    final id = item.id as String;

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

    final typeName = item.type.name as String;
    return _capitalize(typeName);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
