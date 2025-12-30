// TogetherLog - Page Editor Screen
// Interactive scrapbook page editor with drag-drop, resize, rotate capabilities

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/layouts/authenticated_shell.dart';
import 'models/editor_state.dart';
import 'providers/editor_state_provider.dart';
import 'widgets/editor_canvas.dart';
import 'widgets/left_gutter_panel.dart';
import 'widgets/right_gutter_panel.dart';
import 'services/test_data_initializer.dart';

/// Interactive page editor screen
class EditorScreen extends ConsumerStatefulWidget {
  final String entryId;
  final String logId;

  const EditorScreen({
    super.key,
    required this.entryId,
    required this.logId,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _isLeftGutterExpanded = false;
  bool _isRightGutterExpanded = false;
  final GlobalKey<RightGutterPanelState> _rightGutterKey = GlobalKey();
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Handle double-click on text items - expand right gutter and content section
  void _handleTextItemDoubleClick() {
    setState(() {
      _isRightGutterExpanded = true;
    });
    // Use post-frame callback to ensure gutter is expanded before accessing its state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rightGutterKey.currentState?.expandContentSectionAndFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorStateProvider(widget.entryId));

    // Initialize with test data if empty
    // TODO: Remove this and load real entry data
    if (editorState.items.isEmpty) {
      Future.microtask(() {
        ref
            .read(editorStateProvider(widget.entryId).notifier)
            .initialize(initializeTestData(widget.entryId));
      });
    }

    return AuthenticatedShell(
      currentRoute: '/logs/${widget.logId}/entries/${widget.entryId}/page-editor',
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6D3),
        appBar: _buildAppBar(context, ref, editorState),
        body: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(AppColors.darkWalnut.withValues(alpha: 0.7)),
            trackColor: WidgetStateProperty.all(AppColors.oliveWood.withValues(alpha: 0.2)),
            trackBorderColor: WidgetStateProperty.all(AppColors.oliveWood.withValues(alpha: 0.3)),
            thickness: WidgetStateProperty.all(12),
            radius: const Radius.circular(6),
          ),
          child: Stack(
          children: [
            // Full-screen canvas (background layer)
            Positioned(
              left: _isLeftGutterExpanded ? 240 : 48,
              right: _isRightGutterExpanded ? 240 : 48,
              top: 0,
              bottom: 0,
              child: Container(
                color: const Color(0xFFF5E6D3), // Warm tan
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  notificationPredicate: (notification) => notification.depth == 1,
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    notificationPredicate: (notification) => notification.depth == 0,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: EditorCanvas(
                            entryId: widget.entryId,
                            onTextItemDoubleClick: _handleTextItemDoubleClick,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Left Gutter - Floating overlay
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isLeftGutterExpanded ? 240 : 48,
                decoration: BoxDecoration(
                  color: AppColors.antiqueWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: LeftGutterPanel(
                  entryId: widget.entryId,
                  isExpanded: _isLeftGutterExpanded,
                  onToggle: () {
                    setState(() {
                      _isLeftGutterExpanded = !_isLeftGutterExpanded;
                    });
                  },
                ),
              ),
            ),

            // Right Gutter - Floating overlay
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isRightGutterExpanded ? 240 : 48,
                decoration: BoxDecoration(
                  color: AppColors.antiqueWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: RightGutterPanel(
                  key: _rightGutterKey,
                  entryId: widget.entryId,
                  isExpanded: _isRightGutterExpanded,
                  onToggle: () {
                    setState(() {
                      _isRightGutterExpanded = !_isRightGutterExpanded;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
  ) {
    return AppBar(
      backgroundColor: AppColors.antiqueWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _handleBack(context, ref, state),
        tooltip: 'Close editor',
        color: AppColors.carbonBlack,
      ),
      title: Text(
        'Page Editor',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.carbonBlack,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        // Reset button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _handleReset(context, ref),
          tooltip: 'Reset to Smart Page',
          color: AppColors.carbonBlack,
        ),
        const SizedBox(width: AppSpacing.sm),
        // Save button
        FilledButton.icon(
          onPressed: state.isDirty && !state.isSaving
              ? () => _handleSave(context, ref, state)
              : null,
          icon: state.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.antiqueWhite),
                  ),
                )
              : const Icon(Icons.save),
          label: const Text('Save'),
          style: FilledButton.styleFrom(
            backgroundColor: state.isDirty && !state.isSaving
                ? AppColors.darkWalnut
                : AppColors.disabledBackground,
            foregroundColor: AppColors.antiqueWhite,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  void _handleBack(BuildContext context, WidgetRef ref, EditorState state) {
    if (state.isDirty) {
      // Show unsaved changes dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/logs/${widget.logId}/scrapbook');
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSave(context, ref, state);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      context.go('/logs/${widget.logId}/scrapbook');
    }
  }

  void _handleReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Smart Page?'),
        content: const Text(
          'This will discard your customizations and regenerate the page using Smart Page rules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement Smart Page generation
              // ref.read(editorStateProvider(entryId).notifier).generateSmartPage();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Smart Page generation coming soon!'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
  ) async {
    final notifier = ref.read(editorStateProvider(widget.entryId).notifier);

    try {
      notifier.setSaving(true);

      // TODO: Implement save to backend
      // await ref.read(entriesRepositoryProvider).saveCustomLayout(
      //   widget.entryId,
      //   state.toJson(),
      // );

      // Simulate save delay
      await Future.delayed(const Duration(seconds: 1));

      notifier.markAsSaved();
      notifier.setSaving(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page saved successfully!')),
        );
        context.go('/logs/${widget.logId}/scrapbook');
      }
    } catch (e) {
      notifier.setSaving(false);
      notifier.setError('Failed to save: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
