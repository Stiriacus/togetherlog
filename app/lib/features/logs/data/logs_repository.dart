// TogetherLog - Logs Repository
// Repository layer for logs data operations

import '../../../data/api/logs_api_client.dart';
import '../../../data/models/log.dart';

/// Repository for logs data operations
/// Wraps LogsApiClient and provides error handling
class LogsRepository {
  LogsRepository({
    LogsApiClient? apiClient,
  }) : _apiClient = apiClient ?? LogsApiClient();

  final LogsApiClient _apiClient;

  /// Fetch all logs for current user
  Future<List<Log>> fetchLogs() async {
    try {
      final logs = await _apiClient.fetchLogs();
      // Sort by created_at descending (newest first)
      logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return logs;
    } catch (e) {
      throw Exception('Failed to load logs: $e');
    }
  }

  /// Fetch single log by ID
  Future<Log> fetchLog(String id) async {
    try {
      return await _apiClient.fetchLog(id);
    } catch (e) {
      throw Exception('Failed to load log: $e');
    }
  }

  /// Create new log
  Future<Log> createLog({
    required String name,
    required String type,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      throw Exception('Log name cannot be empty');
    }

    if (type.trim().isEmpty) {
      throw Exception('Log type must be selected');
    }

    try {
      return await _apiClient.createLog(
        name: name.trim(),
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to create log: $e');
    }
  }

  /// Update existing log
  Future<Log> updateLog({
    required String id,
    String? name,
    String? type,
  }) async {
    // Validate inputs
    if (name != null && name.trim().isEmpty) {
      throw Exception('Log name cannot be empty');
    }

    if (type != null && type.trim().isEmpty) {
      throw Exception('Log type must be selected');
    }

    try {
      return await _apiClient.updateLog(
        id: id,
        name: name?.trim(),
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to update log: $e');
    }
  }

  /// Delete log
  Future<void> deleteLog(String id) async {
    try {
      await _apiClient.deleteLog(id);
    } catch (e) {
      throw Exception('Failed to delete log: $e');
    }
  }
}
