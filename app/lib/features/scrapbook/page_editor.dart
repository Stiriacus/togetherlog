// TogetherLog - Scrapbook Page Editor
// Interactive editor for customizing scrapbook page layouts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/entry.dart';

/// Scrapbook Page Editor
/// Allows users to interactively edit and customize scrapbook page layouts
///
/// Features (to be implemented):
/// - Drag and drop photos/maps
/// - Rotate items
/// - Resize items
/// - Move decorative icons
/// - Edit text positioning
/// - Real-time preview
class PageEditor extends ConsumerStatefulWidget {
  const PageEditor({
    super.key,
    required this.entry,
    this.onSave,
  });

  final Entry entry;
  final Function(Entry)? onSave;

  @override
  ConsumerState<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends ConsumerState<PageEditor> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize editor state
    // - Load current layout data
    // - Set up gesture controllers
    // - Initialize undo/redo stack
  }

  @override
  void dispose() {
    // TODO: Clean up controllers and listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Page'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // TODO: Add toolbar actions
          // - Undo
          // - Redo
          // - Reset to auto layout
          // - Save
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              // TODO: Implement undo
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              // TODO: Implement redo
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Reset to auto-generated layout
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Save layout and call onSave callback
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Implement editor canvas
            // - Render page at actual size (874×1240)
            // - Enable drag, rotate, resize gestures
            // - Show selection handles
            // - Display grid/guides

            Container(
              width: 874,
              height: 1240,
              color: Colors.grey.shade900,
              child: Center(
                child: Text(
                  'Page Editor Canvas\n(To be implemented)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildToolbar(),
    );
  }

  /// Build bottom toolbar with editing tools
  Widget _buildToolbar() {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // TODO: Add tool buttons
          // - Select/Move tool
          // - Rotate tool
          // - Resize tool
          // - Delete tool
          // - Add icon tool

          _buildToolButton(
            icon: Icons.touch_app,
            label: 'Select',
            onTap: () {
              // TODO: Activate select tool
            },
          ),
          _buildToolButton(
            icon: Icons.rotate_right,
            label: 'Rotate',
            onTap: () {
              // TODO: Activate rotate tool
            },
          ),
          _buildToolButton(
            icon: Icons.photo_size_select_large,
            label: 'Resize',
            onTap: () {
              // TODO: Activate resize tool
            },
          ),
          _buildToolButton(
            icon: Icons.delete,
            label: 'Delete',
            onTap: () {
              // TODO: Delete selected item
            },
          ),
          _buildToolButton(
            icon: Icons.add_circle,
            label: 'Add Icon',
            onTap: () {
              // TODO: Show icon picker
            },
          ),
        ],
      ),
    );
  }

  /// Build a tool button
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
