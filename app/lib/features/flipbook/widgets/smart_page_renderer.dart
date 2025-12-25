// TogetherLog - Smart Page Renderer Widget
// Renders an entry using backend-computed Smart Page layout and theme

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/smart_page_theme.dart';
import '../../../data/models/entry.dart';
import '../../entries/data/entries_repository.dart';
import '../../entries/providers/entries_providers.dart';
import 'layouts/single_full_layout.dart';
import 'layouts/two_by_one_layout.dart';
import 'sprinkles_overlay.dart';

/// Smart Page Renderer - renders an entry based on backend Smart Page data
/// IMPORTANT: This widget does NOT compute layouts or themes - it only renders
/// the pre-computed Smart Page data from the backend
class SmartPageRenderer extends ConsumerStatefulWidget {
  const SmartPageRenderer({
    super.key,
    required this.entry,
  }) : customChild = null;

  /// Custom page constructor for non-entry pages (e.g., "The End" page)
  const SmartPageRenderer.customPage({
    super.key,
    required Widget child,
  })  : entry = null,
        customChild = child;

  final Entry? entry;
  final Widget? customChild;

  @override
  ConsumerState<SmartPageRenderer> createState() => _SmartPageRendererState();
}

class _SmartPageRendererState extends ConsumerState<SmartPageRenderer> {
  bool _isRegenerating = false;

  Future<void> _regenerateLayout() async {
    if (widget.entry == null || _isRegenerating) return;

    setState(() {
      _isRegenerating = true;
    });

    try {
      final repository = EntriesRepository();
      await repository.regenerateLayout(widget.entry!.id);

      // Refresh the entries list to show the updated layout
      // This will cascade to flipbook entries provider
      ref.invalidate(entriesListProvider(widget.entry!.logId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate layout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If custom child is provided, render it directly
    if (widget.customChild != null) {
      return widget.customChild!;
    }

    // Render entry-based page
    if (widget.entry == null) {
      return Container(); // Fallback for invalid state
    }

    // Get color scheme from backend-computed theme
    final colorScheme = SmartPageTheme.getColorScheme(widget.entry!.colorTheme);

    // Select layout widget based on backend-computed layout type
    final layoutWidget = _getLayoutWidget(colorScheme);

    return Stack(
      children: [
        // Layout widget (background)
        layoutWidget,

        // Sprinkles overlay (decorative icons)
        SprinklesOverlay(
          sprinkles: widget.entry!.sprinkles,
          colorScheme: colorScheme,
        ),

        // Regenerate button (top-right corner)
        Positioned(
          top: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isRegenerating ? null : _regenerateLayout,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isRegenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Select appropriate layout widget
  /// Uses pixel-perfect layouts:
  /// - TwoByOneLayout: Photo + Location side by side
  /// - SingleFullLayout: Single photo OR single location
  Widget _getLayoutWidget(ColorScheme colorScheme) {
    final hasPhoto = widget.entry!.photos.isNotEmpty;
    final hasLocation = widget.entry!.location != null;

    // If both photo and location exist, use 2×1 layout
    if (hasPhoto && hasLocation) {
      return TwoByOneLayout(
        entry: widget.entry!,
        colorScheme: colorScheme,
      );
    }

    // Otherwise use single full layout (photo only, location only, or empty)
    return SingleFullLayout(
      entry: widget.entry!,
      colorScheme: colorScheme,
    );
  }
}
