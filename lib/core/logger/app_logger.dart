import 'package:flutter/foundation.dart';

typedef LogExtra = Map<String, dynamic>;

class AppLogger {
  AppLogger._();

  static void info(String message, [LogExtra? extra]) {
    _log('INFO', message, extra);
  }

  static void warn(String message, [LogExtra? extra, Object? error]) {
    _log('WARN', message, extra, error);
  }

  static void error(String message, [LogExtra? extra, Object? error, StackTrace? stack]) {
    _log('ERROR', message, extra, error, stack);
  }

  static void _log(String level, String message, [LogExtra? extra, Object? error, StackTrace? stack]) {
    final ts = DateTime.now().toIso8601String();
    final buf = StringBuffer('🗲 [$ts] [$level] $message');
    if (extra != null && extra.isNotEmpty) {
      buf.write(' | extra: $extra');
    }
    if (error != null) {
      buf.write(' | error: $error');
    }
    if (stack != null) {
      buf.write(' | stack: $stack');
    }
    debugPrint(buf.toString());
  }
}
