// TogetherLog - Entries API Client
// HTTP client for Entries REST API using Dio

import 'package:dio/dio.dart';
import 'supabase_client.dart';

/// Entries API Client
/// Handles all HTTP requests to the Entries REST API
/// Endpoint: https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries
class EntriesApiClient {
  EntriesApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _baseUrl = 'https://ikspskghylahtexiqepl.supabase.co/functions/v1/api-entries';
  }

  final Dio _dio;
  late final String _baseUrl;

  /// Get authorization header with Supabase access token
  Future<Map<String, String>> _getHeaders() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw Exception('User not authenticated');
    }

    return {
      'Authorization': 'Bearer ${session.accessToken}',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch all tags
  /// GET /api-entries/tags
  Future<List<Map<String, dynamic>>> fetchTags() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/tags',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['tags'] as List);
      } else {
        throw Exception('Failed to fetch tags: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error fetching tags: ${e.message}');
    }
  }

  /// Fetch entries for a log
  /// GET /api-entries/logs/:logId/entries
  Future<List<Map<String, dynamic>>> fetchEntries(String logId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/logs/$logId/entries',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data['entries'] as List,
        );
      } else {
        throw Exception('Failed to fetch entries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error fetching entries: ${e.message}');
    }
  }

  /// Fetch a single entry by ID
  /// GET /api-entries/entries/:id
  Future<Map<String, dynamic>> fetchEntry(String entryId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/entries/$entryId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['entry'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error fetching entry: ${e.message}');
    }
  }

  /// Create a new entry
  /// POST /api-entries/logs/:logId/entries
  /// Body: {
  ///   event_date: ISO8601 string,
  ///   highlight_text: string,
  ///   photo_ids: string[],
  ///   tag_ids: string[],
  ///   location?: { lat, lng, display_name, is_user_overridden }
  /// }
  Future<Map<String, dynamic>> createEntry(
    String logId,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/logs/$logId/entries',
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        return response.data['entry'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to create entry: ${e.response!.data['error'] ?? e.message}',
        );
      }
      throw Exception('Network error creating entry: ${e.message}');
    }
  }

  /// Update an existing entry
  /// PATCH /api-entries/entries/:id
  /// Body: {
  ///   event_date?: ISO8601 string,
  ///   highlight_text?: string,
  ///   photo_ids?: string[],
  ///   tag_ids?: string[],
  ///   location?: { lat, lng, display_name, is_user_overridden }
  /// }
  Future<Map<String, dynamic>> updateEntry(
    String entryId,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '$_baseUrl/entries/$entryId',
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data['entry'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to update entry: ${e.response!.data['error'] ?? e.message}',
        );
      }
      throw Exception('Network error updating entry: ${e.message}');
    }
  }

  /// Delete an entry
  /// DELETE /api-entries/entries/:id
  Future<void> deleteEntry(String entryId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '$_baseUrl/entries/$entryId',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete entry: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to delete entry: ${e.response!.data['error'] ?? e.message}',
        );
      }
      throw Exception('Network error deleting entry: ${e.message}');
    }
  }
}
