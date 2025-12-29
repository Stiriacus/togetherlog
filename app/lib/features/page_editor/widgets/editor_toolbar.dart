// TogetherLog - Editor Toolbar Widget
// Toolbar with options for photos, decorations, and background color

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/editor_state_provider.dart';

/// Editor toolbar (placeholder for now)
class EditorToolbar extends ConsumerWidget {
  final String entryId;
  final bool isLayersPanelExpanded;
  final VoidCallback onToggleLayers;

  const EditorToolbar({
    super.key,
    required this.entryId,
    required this.isLayersPanelExpanded,
    required this.onToggleLayers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider(entryId));
    final hasSelection = editorState.selectedItemId != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.softApricot,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Delete button (only visible when item is selected)
          if (hasSelection) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ref.read(editorStateProvider(entryId).notifier).removeItem(editorState.selectedItemId!);
              },
              tooltip: 'Delete',
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          _buildToolbarButton(
            icon: Icons.photo_library,
            label: 'Photos',
            onPressed: () {
              // TODO: Implement photos panel
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildToolbarButton(
            icon: Icons.image,
            label: 'Decorations',
            onPressed: () {
              // TODO: Implement decorations picker
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildToolbarButton(
            icon: Icons.palette,
            label: 'Background',
            onPressed: () {
              // TODO: Implement background color picker
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildToolbarButton(
            icon: Icons.layers,
            label: 'Layers',
            isActive: isLayersPanelExpanded,
            onPressed: onToggleLayers,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? AppColors.antiqueWhite : AppColors.darkWalnut,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.antiqueWhite : AppColors.darkWalnut,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isActive
              ? AppColors.darkWalnut
              : AppColors.oliveWood.withValues(alpha: 0.3),
        ),
        backgroundColor: isActive ? AppColors.darkWalnut : AppColors.antiqueWhite,
      ),
    );
  }
}
