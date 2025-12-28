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
import 'widgets/editor_toolbar.dart';
import 'widgets/layers_panel.dart';
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
  bool _isLayersPanelExpanded = false; // Collapsed by default
  late final ScrollController _verticalScrollController;
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
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
        backgroundColor: AppColors.antiqueWhite,
        appBar: _buildAppBar(context, ref, editorState),
        body: Row(
          children: [
            // Main editor area (canvas + toolbar)
            Expanded(
              child: Container(
                color: const Color(0xFFF5E6D3), // Warm tan - between antiqueWhite and softApricot
                child: Column(
                  children: [
                    // Toolbar
                    Container(
                      color: AppColors.antiqueWhite,
                      child: EditorToolbar(
                        entryId: widget.entryId,
                        isLayersPanelExpanded: _isLayersPanelExpanded,
                        onToggleLayers: () {
                          setState(() {
                            _isLayersPanelExpanded = !_isLayersPanelExpanded;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Canvas (scrollable with visible scrollbars)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            controller: _verticalScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalScrollController,
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: Scrollbar(
                                controller: _horizontalScrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                  ),
                                  child: EditorCanvas(entryId: widget.entryId),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Collapsible Layers panel (right side)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isLayersPanelExpanded ? 320 : 0,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.antiqueWhite,
                border: Border(
                  left: BorderSide(
                    color: AppColors.divider,
                    width: _isLayersPanelExpanded ? 1 : 0,
                  ),
                ),
                boxShadow: _isLayersPanelExpanded
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(-2, 0),
                        ),
                      ]
                    : null,
              ),
              child: _isLayersPanelExpanded
                  ? SizedBox(
                      width: 320,
                      child: LayersPanel(entryId: widget.entryId),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
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
