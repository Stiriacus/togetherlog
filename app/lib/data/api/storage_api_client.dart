// TogetherLog - Storage API Client
// Handles photo uploads to Supabase Storage

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Storage API Client
/// Handles photo uploads to Supabase Storage buckets
/// Uses Supabase Storage API for photo and thumbnail management
class StorageApiClient {
  /// Upload a photo to Supabase Storage
  /// Returns the path of the uploaded file
  /// Bucket: 'photos'
  /// Path format: {userId}/{entryId}/{timestamp}_{filename}
  Future<String> uploadPhoto({
    required Uint8List fileBytes,
    required String fileName,
    required String entryId,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Sanitize filename: remove special characters, keep only alphanumeric, dots, dashes, underscores
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/$entryId/${timestamp}_$sanitizedFileName';

      // Upload to 'photos' bucket
      await supabase.storage.from('photos').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Get authenticated URL for a photo
  /// Bucket: 'photos'
  /// For private buckets with RLS, we need to create a signed URL
  Future<String> getPhotoUrl(String path) async {
    try {
      // For private buckets, create a signed URL valid for 1 year
      final signedUrl = await supabase.storage
          .from('photos')
          .createSignedUrl(path, 60 * 60 * 24 * 365); // 1 year
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get photo URL: $e');
    }
  }

  /// Get authenticated URL for a thumbnail
  /// Bucket: 'thumbnails'
  Future<String> getThumbnailUrl(String path) async {
    try {
      // For private buckets, create a signed URL valid for 1 year
      final signedUrl = await supabase.storage
          .from('thumbnails')
          .createSignedUrl(path, 60 * 60 * 24 * 365); // 1 year
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to get thumbnail URL: $e');
    }
  }

  /// Delete a photo from storage
  /// Bucket: 'photos'
  Future<void> deletePhoto(String path) async {
    try {
      await supabase.storage.from('photos').remove([path]);
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  /// Delete a thumbnail from storage
  /// Bucket: 'thumbnails'
  Future<void> deleteThumbnail(String path) async {
    try {
      await supabase.storage.from('thumbnails').remove([path]);
    } catch (e) {
      throw Exception('Failed to delete thumbnail: $e');
    }
  }

  /// Upload multiple photos
  /// Returns list of file paths
  Future<List<String>> uploadPhotos({
    required List<Uint8List> filesBytes,
    required List<String> fileNames,
    required String entryId,
  }) async {
    if (filesBytes.length != fileNames.length) {
      throw Exception('Files and file names count mismatch');
    }

    final paths = <String>[];

    for (var i = 0; i < filesBytes.length; i++) {
      final path = await uploadPhoto(
        fileBytes: filesBytes[i],
        fileName: fileNames[i],
        entryId: entryId,
      );
      paths.add(path);
    }

    return paths;
  }
}
