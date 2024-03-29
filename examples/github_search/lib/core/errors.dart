import 'dart:async';
import 'dart:io';

class AppError implements Exception {
  const AppError(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  const NetworkError([String? message])
      : super(
          message ?? 'Network error. Check your internet connection.',
        );
}

class ServerError extends AppError {
  const ServerError([String? message])
      : super(
          message ?? 'Server error, please try again later',
        );
}

class UnknownError extends AppError {
  const UnknownError([String? message]) : super(message ?? 'Unknown error');
}

FutureOr<T> tryRun<T>(FutureOr<T> Function() f) async {
  try {
    final result = await f(); // Await for both Future and non-Future results
    return result;
  } catch (e) {
    throw e.toAppError();
  }
}

AppError genericToAppError(Object? error) => error.toAppError();

extension AppErrorX on Object? {
  AppError toAppError() => switch (this) {
        final AppError e => e,
        SocketException => const NetworkError(),
        FormatException => const ServerError('Invalid data received'),
        _ => const UnknownError()
      };
}
