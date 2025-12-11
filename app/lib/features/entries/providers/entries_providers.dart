// TogetherLog - Entries Providers
// Riverpod state management for entries

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/entries_repository.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/tag.dart';

/// Entries repository provider
final entriesRepositoryProvider = Provider<EntriesRepository>((ref) {
  return EntriesRepository();
});

/// Tags list provider
/// Fetches all available tags from the backend
final tagsListProvider = FutureProvider<List<Tag>>((ref) async {
  final repository = ref.read(entriesRepositoryProvider);
  return repository.fetchTags();
});

/// Entries list provider for a specific log
/// Fetches all entries for the given log ID
final entriesListProvider =
    FutureProvider.family<List<Entry>, String>((ref, logId) async {
  final repository = ref.read(entriesRepositoryProvider);
  return repository.fetchEntries(logId);
});

/// Single entry detail provider
/// Fetches a specific entry by ID
final entryDetailProvider =
    FutureProvider.family<Entry, String>((ref, entryId) async {
  final repository = ref.read(entriesRepositoryProvider);
  return repository.fetchEntry(entryId);
});

/// Entry operations notifier
/// Handles create, update, delete operations for entries
class EntryNotifier extends StateNotifier<AsyncValue<void>> {
  EntryNotifier(this._repository) : super(const AsyncValue.data(null));

  final EntriesRepository _repository;

  /// Create a new entry
  Future<Entry> createEntry({
    required String logId,
    required DateTime eventDate,
    required String highlightText,
    required List<String> tagIds,
    List<dynamic>? photoBytes,
    List<String>? photoFileNames,
    Location? location,
  }) async {
    state = const AsyncValue.loading();
    try {
      final entry = await _repository.createEntry(
        logId: logId,
        eventDate: eventDate,
        highlightText: highlightText,
        tagIds: tagIds,
        photoBytes: photoBytes?.cast(),
        photoFileNames: photoFileNames,
        location: location,
      );
      state = const AsyncValue.data(null);
      return entry;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update an existing entry
  Future<Entry> updateEntry({
    required String entryId,
    DateTime? eventDate,
    String? highlightText,
    List<String>? tagIds,
    Location? location,
  }) async {
    state = const AsyncValue.loading();
    try {
      final entry = await _repository.updateEntry(
        entryId: entryId,
        eventDate: eventDate,
        highlightText: highlightText,
        tagIds: tagIds,
        location: location,
      );
      state = const AsyncValue.data(null);
      return entry;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete an entry
  Future<void> deleteEntry(String entryId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteEntry(entryId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Entry notifier provider
final entryNotifierProvider =
    StateNotifierProvider<EntryNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(entriesRepositoryProvider);
  return EntryNotifier(repository);
});
