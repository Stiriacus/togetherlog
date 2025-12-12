// TogetherLog - Flipbook Viewer
// 3D page-turn flipbook viewer for entries

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_flip/page_flip.dart';
import 'providers/flipbook_providers.dart';
import 'widgets/smart_page_renderer.dart';

/// Flipbook viewer with 3D page-turn animation
/// Displays all entries of a log in chronological order
class FlipbookViewer extends ConsumerStatefulWidget {
  const FlipbookViewer({
    super.key,
    required this.logId,
    required this.logName,
  });

  final String logId;
  final String logName;

  @override
  ConsumerState<FlipbookViewer> createState() => _FlipbookViewerState();
}

class _FlipbookViewerState extends ConsumerState<FlipbookViewer> {
  final _pageFlipKey = GlobalKey<PageFlipWidgetState>();

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(flipbookEntriesProvider(widget.logId));

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(widget.logName),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFlipbook(entries);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some memories to start your flipbook',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load flipbook',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFlipbook(List entries) {
    // Build page widgets
    final pages = entries
        .map((entry) => SmartPageRenderer(entry: entry))
        .toList();

    // Add last page
    pages.add(
      SmartPageRenderer.customPage(
        child: Container(
          color: Colors.grey.shade800,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'The End',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve reached the end of this log',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // Page flip widget
        Center(
          child: AspectRatio(
            aspectRatio: 0.7, // Portrait book aspect ratio
            child: PageFlipWidget(
              key: _pageFlipKey,
              backgroundColor: Colors.grey.shade900,
              children: pages,
            ),
          ),
        ),

        // Navigation controls overlay
        _buildNavigationControls(entries.length),
      ],
    );
  }

  Widget _buildNavigationControls(int totalPages) {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: () {
              _pageFlipKey.currentState?.previousPage();
            },
            icon: const Icon(Icons.chevron_left),
            iconSize: 48,
            color: Colors.white.withValues(alpha: 0.8),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 24),

          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final currentPage = ref.watch(currentPageIndexProvider);
                return Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 24),

          // Next button
          IconButton(
            onPressed: () {
              _pageFlipKey.currentState?.nextPage();
            },
            icon: const Icon(Icons.chevron_right),
            iconSize: 48,
            color: Colors.white.withValues(alpha: 0.8),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
