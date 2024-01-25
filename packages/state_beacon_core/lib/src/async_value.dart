// ignore_for_file: use_setters_to_change_properties, avoid_equals_and_hash_code_on_mutable_classes, lines_longer_than_80_chars

import 'package:state_beacon_core/src/base_beacon.dart';

/// A class that represents a value that is loaded asynchronously.
/// It can be in one of the following states:
/// - [AsyncIdle] - the initial state
/// - [AsyncLoading] - when the value is being loaded
/// - [AsyncData] - when the value is successfully loaded
/// - [AsyncError] - when an error occurred while loading the value
sealed class AsyncValue<T> {
  T? _oldData;

  /// This is useful when manually hanlding async state
  /// and you want to keep track of the last successful data.
  /// You can use the `lastData` getter to retrieve the last successful data
  /// when in [AsyncError] or [AsyncLoading] state.
  void setLastData(T? value) {
    _oldData = value;
  }

  /// If this is [AsyncData], returns it's value.
  /// Otherwise returns `null`.
  T? get valueOrNull {
    if (this case AsyncData<T>(:final value)) {
      return value;
    }
    return null;
  }

  /// Returns the last data that was successfully loaded
  /// This is useful when the current state is [AsyncError] or [AsyncLoading]
  T? get lastData => valueOrNull ?? _oldData;

  /// Casts this [AsyncValue] to [AsyncData] and return it's value
  /// or throws `CastError` if this is not [AsyncData].
  T unwrap() {
    return (this as AsyncData<T>).value;
  }

  /// Returns `true` if this is [AsyncLoading].
  bool get isLoading => this is AsyncLoading;

  /// Returns `true` if this is [AsyncIdle].
  bool get isIdle => this is AsyncIdle;

  /// Returns `true` if this is [AsyncIdle] or [AsyncLoading].
  bool get isIdleOrLoading => this is AsyncIdle || this is AsyncLoading;

  /// Returns `true` if this is [AsyncData].
  bool get isData => this is AsyncData;

  /// Returns `true` if this is [AsyncError].
  bool get isError => this is AsyncError;

  /// Executes the future provided and returns [AsyncData] with the result
  /// if successful or [AsyncError] if an exception is thrown.
  ///
  /// Supply an optional [WritableBeacon] that will be set throughout the
  /// various states.
  ///
  /// Supply an optional [optimisticResult] that will be set while loadin, instead of [AsyncLoading].
  ///
  /// /// Example:
  /// ```dart
  /// Future<String> fetchUserData() {
  ///   // Imagine this is a network request that might throw an error
  ///   return Future.delayed(Duration(seconds: 1), () => 'User data');
  /// }
  ///
  ///   beacon.value = AsyncLoading();
  ///   beacon.value = await AsyncValue.tryCatch(fetchUserData);
  ///```
  /// You can also pass the beacon as a parameter.
  /// `loading`,`data` and `error` states,
  /// as well as the last successful data will be set automatically.
  ///```dart
  ///  await AsyncValue.tryCatch(fetchUserData, beacon: beacon);
  /// ```
  ///
  /// Without `tryCatch`, handling the potential error requires more
  /// boilerplate code:
  /// ```dart
  ///   beacon.value = AsyncLoading();
  ///   try {
  ///     beacon.value = AsyncData(await fetchUserData());
  ///   } catch (err,stacktrace) {
  ///     beacon.value = AsyncError(err, stacktrace);
  ///   }
  /// ```
  static Future<AsyncValue<T>> tryCatch<T>(
    Future<T> Function() future, {
    WritableBeacon<AsyncValue<T>>? beacon,
    T? optimisticResult,
  }) async {
    T? oldData;

    if (beacon != null) {
      oldData = beacon.peek().lastData;

      if (optimisticResult != null) {
        beacon.set(AsyncData(optimisticResult));
      } else {
        beacon.set(AsyncLoading()..setLastData(oldData));
      }
    }

    try {
      final data = AsyncData(await future());
      beacon?.set(data);
      return data;
    } catch (e, s) {
      final error = AsyncError<T>(e, s)..setLastData(oldData);
      beacon?.set(error);
      return error;
    }
  }
}

/// A class that represents a value that is loaded asynchronously.
class AsyncData<T> extends AsyncValue<T> {
  /// Creates an instance of [AsyncData].
  AsyncData(this.value);

  /// The value that was loaded.
  final T value;

  @override
  String toString() {
    return 'AsyncData{value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => toString().hashCode ^ value.hashCode;
}

/// A class that represents an error that occurred while loading a value.
class AsyncError<T> extends AsyncValue<T> {
  /// Creates an instance of [AsyncError].
  AsyncError(this.error, [StackTrace? stackTrace])
      : stackTrace = stackTrace ?? StackTrace.current;

  /// The error that occurred.
  final Object error;

  /// The stack trace of the error.
  final StackTrace stackTrace;

  @override
  bool operator ==(Object other) =>
      other is AsyncError<T> &&
      other.error == error &&
      other.stackTrace == stackTrace;

  @override
  int get hashCode =>
      toString().hashCode ^ error.hashCode ^ stackTrace.hashCode;
}

/// A class that represents a value that is being loaded asynchronously.
class AsyncLoading<T> extends AsyncValue<T> {
  @override
  bool operator ==(Object other) => other is AsyncLoading<T>;

  @override
  int get hashCode => toString().hashCode;
}

/// A class that represents an idle state.
class AsyncIdle<T> extends AsyncValue<T> {
  @override
  bool operator ==(Object other) => other is AsyncIdle<T>;

  @override
  int get hashCode => toString().hashCode;
}
