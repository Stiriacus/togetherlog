// TogetherLog - Entries Repository
// Business logic layer for entries operations

import 'dart:typed_data';
import '../../../data/api/entries_api_client.dart';
import '../../../data/api/storage_api_client.dart';
import '../../../data/api/supabase_client.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/tag.dart';

/// Entries Repository
/// Handles all business logic for entries, including validation and API calls
class EntriesRepository {
  EntriesRepository({
    EntriesApiClient? entriesApiClient,
    StorageApiClient? storageApiClient,
  })  : _entriesApiClient = entriesApiClient ?? EntriesApiClient(),
        _storageApiClient = storageApiClient ?? StorageApiClient();

  final EntriesApiClient _entriesApiClient;
  final StorageApiClient _storageApiClient;

  /// Fetch all tags
  Future<List<Tag>> fetchTags() async {
    final tagsJson = await _entriesApiClient.fetchTags();
    return tagsJson.map((json) => Tag.fromJson(json)).toList();
  }

  /// Fetch entries for a log
  Future<List<Entry>> fetchEntries(String logId) async {
    if (logId.isEmpty) {
      throw Exception('Log ID cannot be empty');
    }

    final entriesJson = await _entriesApiClient.fetchEntries(logId);
    return entriesJson.map((json) => Entry.fromJson(json)).toList();
  }

  /// Fetch a single entry
  Future<Entry> fetchEntry(String entryId) async {
    if (entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }

    final entryJson = await _entriesApiClient.fetchEntry(entryId);
    return Entry.fromJson(entryJson);
  }

  /// Create a new entry with photos
  /// Steps:
  /// 1. Upload photos to Supabase Storage
  /// 2. Create entry with photo paths
  /// 3. Backend workers will process photos and compute Smart Page
  Future<Entry> createEntry({
    required String logId,
    required DateTime eventDate,
    required String highlightText,
    required List<String> tagIds,
    List<Uint8List>? photoBytes,
    List<String>? photoFileNames,
    Location? location,
  }) async {
    // Validation
    if (logId.isEmpty) {
      throw Exception('Log ID cannot be empty');
    }
    if (highlightText.isEmpty) {
      throw Exception('Highlight text cannot be empty');
    }
    if (photoBytes != null && photoFileNames != null) {
      if (photoBytes.length != photoFileNames.length) {
        throw Exception('Photo bytes and file names count mismatch');
      }
      if (photoBytes.length > 6) {
        throw Exception('Maximum 6 photos allowed per entry');
      }
    }

    // Create entry first to get entry ID
    final createData = <String, dynamic>{
      'event_date': eventDate.toIso8601String(),
      'highlight_text': highlightText,
      'tag_ids': tagIds,
      'photo_ids': <String>[], // Empty initially
    };

    // Flatten location data for backend API
    if (location != null) {
      if (location.lat != null) createData['location_lat'] = location.lat;
      if (location.lng != null) createData['location_lng'] = location.lng;
      createData['location_display_name'] = location.displayName;
      createData['location_is_user_overridden'] = location.isUserOverridden;
    }

    final entryJson = await _entriesApiClient.createEntry(logId, createData);
    final entry = Entry.fromJson(entryJson);

    // Upload photos if provided
    if (photoBytes != null &&
        photoFileNames != null &&
        photoBytes.isNotEmpty) {
      try {
        // Step 1: Upload photos to Storage
        final photoPaths = await _storageApiClient.uploadPhotos(
          filesBytes: photoBytes,
          fileNames: photoFileNames,
          entryId: entry.id,
        );

        // Step 2: Create photo records in database and get photo IDs
        final photoIds = await _createPhotoRecords(
          entryId: entry.id,
          storagePaths: photoPaths,
        );

        // Step 2.5: Update Smart Page layout based on photo count
        await _updateSmartPageLayout(entry.id, photoIds.length);

        // Step 3: Fetch the updated entry with photos
        // Note: Photos are already linked via entry_id foreign key,
        // no need to update the entry itself
        final updatedEntryJson = await _entriesApiClient.fetchEntry(entry.id);

        return Entry.fromJson(updatedEntryJson);
      } catch (e) {
        // If photo upload fails, delete the entry to maintain consistency
        await _entriesApiClient.deleteEntry(entry.id);
        throw Exception('Failed to upload photos: $e');
      }
    }

    return entry;
  }

  /// Update an existing entry
  Future<Entry> updateEntry({
    required String entryId,
    DateTime? eventDate,
    String? highlightText,
    List<String>? tagIds,
    Location? location,
  }) async {
    if (entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }

    final updateData = <String, dynamic>{};

    if (eventDate != null) {
      updateData['event_date'] = eventDate.toIso8601String();
    }
    if (highlightText != null) {
      if (highlightText.isEmpty) {
        throw Exception('Highlight text cannot be empty');
      }
      updateData['highlight_text'] = highlightText;
    }
    if (tagIds != null) {
      updateData['tag_ids'] = tagIds;
    }
    // Flatten location data for backend API
    if (location != null) {
      if (location.lat != null) updateData['location_lat'] = location.lat;
      if (location.lng != null) updateData['location_lng'] = location.lng;
      updateData['location_display_name'] = location.displayName;
      updateData['location_is_user_overridden'] = location.isUserOverridden;
    }

    if (updateData.isEmpty) {
      throw Exception('No data to update');
    }

    final entryJson = await _entriesApiClient.updateEntry(entryId, updateData);
    return Entry.fromJson(entryJson);
  }

  /// Delete an entry
  Future<void> deleteEntry(String entryId) async {
    if (entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }

    await _entriesApiClient.deleteEntry(entryId);
  }

  /// Upload additional photos to an existing entry
  Future<Entry> addPhotosToEntry({
    required String entryId,
    required List<Uint8List> photoBytes,
    required List<String> photoFileNames,
  }) async {
    if (entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }
    if (photoBytes.isEmpty) {
      throw Exception('No photos to upload');
    }
    if (photoBytes.length != photoFileNames.length) {
      throw Exception('Photo bytes and file names count mismatch');
    }

    // Upload photos
    final photoPaths = await _storageApiClient.uploadPhotos(
      filesBytes: photoBytes,
      fileNames: photoFileNames,
      entryId: entryId,
    );

    // Fetch current entry to get existing photo IDs
    final currentEntry = await fetchEntry(entryId);
    final currentPhotoIds = currentEntry.photos.map((p) => p.id).toList();

    // Combine with new photo paths
    final allPhotoIds = [...currentPhotoIds, ...photoPaths];

    if (allPhotoIds.length > 6) {
      throw Exception('Maximum 6 photos allowed per entry');
    }

    // Update entry with combined photo IDs
    final updateData = <String, dynamic>{
      'photo_ids': allPhotoIds,
    };

    final updatedEntryJson = await _entriesApiClient.updateEntry(
      entryId,
      updateData,
    );

    return Entry.fromJson(updatedEntryJson);
  }

  /// Create photo records in the database
  /// Returns list of photo IDs (UUIDs)
  Future<List<String>> _createPhotoRecords({
    required String entryId,
    required List<String> storagePaths,
  }) async {
    final photoIds = <String>[];

    for (var i = 0; i < storagePaths.length; i++) {
      final storagePath = storagePaths[i];

      // Validate storage path
      if (storagePath.isEmpty) {
        throw Exception('Storage path is empty for photo at index $i');
      }

      // Generate authenticated URLs for the photo
      final url = await _storageApiClient.getPhotoUrl(storagePath);

      // Validate URL
      if (url.isEmpty) {
        throw Exception('Generated URL is empty for storage path: $storagePath');
      }

      // For V1, use same URL for thumbnail (proper thumbnail generation is Milestone 6 enhancement)
      final thumbnailUrl = url;

      // Insert photo record into database
      try {
        final response = await supabase.from('photos').insert({
          'entry_id': entryId,
          'storage_path': storagePath,
          'url': url,
          'thumbnail_url': thumbnailUrl,
          'display_order': i,
        }).select().single();

        final photoId = response['id'] as String;
        photoIds.add(photoId);
      } catch (e) {
        throw Exception('Failed to insert photo record (path: $storagePath): $e');
      }
    }

    return photoIds;
  }

  /// Regenerate layout variant for an entry
  /// Increments the layoutVariant field to trigger new random positioning
  Future<Entry> regenerateLayout(String entryId) async {
    if (entryId.isEmpty) {
      throw Exception('Entry ID cannot be empty');
    }

    // Fetch current entry to get current layoutVariant
    final currentEntry = await fetchEntry(entryId);
    final newVariant = currentEntry.layoutVariant + 1;

    // Update layoutVariant in database
    final updateData = <String, dynamic>{
      'layout_variant': newVariant,
    };

    final entryJson = await _entriesApiClient.updateEntry(entryId, updateData);
    return Entry.fromJson(entryJson);
  }

  /// Update Smart Page layout type based on photo count
  /// Implements basic Smart Pages Engine Rule 1: Layout Type Selection
  Future<void> _updateSmartPageLayout(String entryId, int photoCount) async {
    // RULE 1: Layout Type Selection based on photo count
    String layoutType;
    if (photoCount == 0 || photoCount == 1) {
      layoutType = 'single_full';
    } else if (photoCount >= 2 && photoCount <= 4) {
      layoutType = 'grid_2x2';
    } else {
      // 5-6 photos
      layoutType = 'grid_3x2';
    }

    // Update entry with computed layout
    await supabase.from('entries').update({
      'page_layout_type': layoutType,
      'is_processed': true,
    }).eq('id', entryId);
  }
}
