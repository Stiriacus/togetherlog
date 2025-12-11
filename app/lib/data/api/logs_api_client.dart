// TogetherLog - Logs API Client
// HTTP client for Logs REST API using Dio

import 'package:dio/dio.dart';
import '../models/log.dart';
import 'supabase_client.dart';

/// API client for logs CRUD operations
/// Connects to Supabase Edge Function: /api-logs
class LogsApiClient {
  LogsApiClient({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? 'https://ikspskghylahtexiqepl.supabase.co/functions/v1' {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptor for auth headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get current auth token from Supabase
          final session = supabase.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          return handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  final String _baseUrl;

  /// Fetch all logs for current user
  /// GET /api-logs
  Future<List<Log>> fetchLogs() async {
    try {
      final response = await _dio.get('/api-logs');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => Log.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw Exception('Failed to fetch logs: Invalid response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }
      throw Exception('Failed to fetch logs: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch logs: $e');
    }
  }

  /// Fetch single log by ID
  /// GET /api-logs/:id
  Future<Log> fetchLog(String id) async {
    try {
      final response = await _dio.get('/api-logs/$id');

      if (response.statusCode == 200 && response.data != null) {
        return Log.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch log: Invalid response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Log not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }
      throw Exception('Failed to fetch log: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch log: $e');
    }
  }

  /// Create new log
  /// POST /api-logs
  /// Body: {name: string, type: string}
  Future<Log> createLog({
    required String name,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '/api-logs',
        data: {
          'name': name,
          'type': type,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return Log.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create log: Invalid response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data: ${e.response?.data?['error'] ?? 'Bad request'}');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }
      throw Exception('Failed to create log: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create log: $e');
    }
  }

  /// Update existing log
  /// PATCH /api-logs/:id
  /// Body: {name?: string, type?: string}
  Future<Log> updateLog({
    required String id,
    String? name,
    String? type,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (type != null) data['type'] = type;

      final response = await _dio.patch(
        '/api-logs/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        return Log.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to update log: Invalid response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Log not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data: ${e.response?.data?['error'] ?? 'Bad request'}');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }
      throw Exception('Failed to update log: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update log: $e');
    }
  }

  /// Delete log
  /// DELETE /api-logs/:id
  Future<void> deleteLog(String id) async {
    try {
      final response = await _dio.delete('/api-logs/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete log: Invalid response');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Log not found');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      }
      throw Exception('Failed to delete log: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete log: $e');
    }
  }
}
