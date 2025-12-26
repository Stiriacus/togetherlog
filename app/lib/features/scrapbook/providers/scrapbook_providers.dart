// TogetherLog - Scrapbook Providers
// Riverpod state management for scrapbook viewer

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/entry.dart';
import '../../entries/providers/entries_providers.dart';

/// Scrapbook entries provider for a specific log
/// Fetches entries sorted chronologically (oldest first for scrapbook reading)
final scrapbookEntriesProvider =
    FutureProvider.family<List<Entry>, String>((ref, logId) async {
  // Reuse the entries list provider from entries feature
  final entries = await ref.watch(entriesListProvider(logId).future);

  // Sort entries chronologically (oldest first)
  // This matches the scrapbook reading experience (start from first memory)
  final sortedEntries = List<Entry>.from(entries)
    ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

  return sortedEntries;
});

/// Current page index provider
/// Tracks which page the user is currently viewing
final currentPageIndexProvider = StateProvider<int>((ref) => 0);

/// Total pages count provider
/// Returns the total number of pages in the scrapbook
final totalPagesProvider =
    Provider.family<int, String>((ref, logId) {
  final entriesAsync = ref.watch(scrapbookEntriesProvider(logId));

  return entriesAsync.when(
    data: (entries) => entries.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
