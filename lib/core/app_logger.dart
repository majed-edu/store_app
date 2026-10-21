import 'package:flutter/foundation.dart';

/// Prints readable messages in the terminal (flutter run / flutter test).
///
/// Every network call goes through [AppLog.run], so while you develop you can
/// watch each task start, finish, and how long it took.
class AppLog {
  static void info(String tag, String message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  /// Runs [action] and prints: ▶ start, ✔ success (with time) or ✘ failure.
  static Future<T> run<T>(
    String task,
    Future<T> Function() action, {
    String Function(T result)? onSuccess,
  }) async {
    final stopwatch = Stopwatch()..start();
    info('TASK', '▶ $task');
    try {
      final result = await action();
      final details = onSuccess == null ? '' : ' → ${onSuccess(result)}';
      info('TASK', '✔ $task (${stopwatch.elapsedMilliseconds} ms)$details');
      return result;
    } catch (error) {
      info('TASK', '✘ $task failed after ${stopwatch.elapsedMilliseconds} ms: $error');
      rethrow;
    }
  }
}
