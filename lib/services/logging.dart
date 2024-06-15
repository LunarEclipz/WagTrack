import 'package:logger/logger.dart';

/// Wrapper class to handle logging for WagTrack
///
/// https://pub.dev/packages/logger
///
/// ## Levels
///
/// ### `d` Debug
///
/// Detailed information for debugging purposes. Use for:
/// - Running methods
/// - Calling APIs
///
/// ### `i` Info
///
/// General operation information about app flow.
/// - Successful login
/// - Loading a screen
/// - Significant stages in app flow
///
/// ### `w` Warning
///
/// Potentially harmful situations.
/// Issues that do not stop the application but may need attention.
///
/// ### `e` Error
///
/// Error events
/// - Catching exceptions
/// - Major failures in critical operations
/// - Capturing stack traces
///
/// ### `t` Trace
///
/// Detailed logging. May use to trace through every step of a **complex**
/// operation.
class AppLogger {
  /// Main `Logger` instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  /// Log a messsage at level [Level.debug].
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.error].
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.info].
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.warning].
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.trace].
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
}
