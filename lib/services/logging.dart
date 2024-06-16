import 'package:logger/logger.dart';

/// Wrapper class to handle logging for WagTrack
///
/// https://pub.dev/packages/logger
///
/// ## Levels
///
/// In Order of severity:
/// `trace` < `debug` < `info` < `warning` < `error`
///
/// ---
///
/// ### `t` Trace
///
/// Detailed logging. May use to trace through every step of a **complex**
/// operation.
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
/// Issues that **do not stop** the application but may need attention.
///
/// ### `e` Error
///
/// Error events
/// - Catching exceptions
/// - Major failures in critical operations
/// - Capturing stack traces
///
///
class AppLogger {
  // Set logging level
  static const Level logLevel = Level.trace;

  /// Main `Logger` instance
  ///
  /// TODO changes:
  /// - change method count - only include for warning and error??
  /// - change print time to debug only?
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
    level: logLevel,
  );

  /// Log a messsage at level [Level.trace].
  ///
  /// Detailed logging. May use to trace through every step of a **complex**
  /// operation.
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.debug].
  ///
  /// Detailed information for debugging purposes. Use for:
  /// - Running methods
  /// - Calling APIs
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.error].
  ///
  /// Error events
  /// - Catching exceptions
  /// - Major failures in critical operations
  /// - Capturing stack traces
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.info].
  ///
  /// General operation information about app flow.
  /// - Successful login
  /// - Loading a screen
  /// - Significant stages in app flow
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a messsage at level [Level.warning].
  ///
  /// Potentially harmful situations.
  /// Issues that **do not stop** the application but may need attention.
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
}