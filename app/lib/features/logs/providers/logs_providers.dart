// TogetherLog - Logs Providers (Riverpod)
// State management for logs feature

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/log.dart';
import '../data/logs_repository.dart';

/// Provider for LogsRepository instance
final logsRepositoryProvider = Provider<LogsRepository>((ref) {
  return LogsRepository();
});

/// Provider for logs list
/// Returns list of all logs for current user
final logsListProvider = FutureProvider<List<Log>>((ref) async {
  final repository = ref.watch(logsRepositoryProvider);
  return repository.fetchLogs();
});

/// Provider for single log by ID
/// Family provider that takes log ID as parameter
final logProvider = FutureProvider.family<Log, String>((ref, id) async {
  final repository = ref.watch(logsRepositoryProvider);
  return repository.fetchLog(id);
});

/// StateNotifier for managing log creation/update/delete operations
class LogsNotifier extends StateNotifier<AsyncValue<void>> {
  LogsNotifier(this._repository) : super(const AsyncValue.data(null));

  final LogsRepository _repository;

  /// Create new log
  Future<void> createLog({
    required String name,
    required String type,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createLog(name: name, type: type);
    });
  }

  /// Update existing log
  Future<void> updateLog({
    required String id,
    String? name,
    String? type,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateLog(id: id, name: name, type: type);
    });
  }

  /// Delete log
  Future<void> deleteLog(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteLog(id);
    });
  }
}

/// Provider for LogsNotifier
final logsNotifierProvider = StateNotifierProvider<LogsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(logsRepositoryProvider);
  return LogsNotifier(repository);
});
