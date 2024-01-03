import 'package:state_beacon/src/base_beacon.dart';

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
  /// or throws [CastError] if this is not [AsyncData].
  T unwrapValue() {
    return (this as AsyncData<T>).value;
  }

  /// Returns `true` if this is [AsyncLoading] or [AsyncIdle].
  bool get isLoading => this is AsyncLoading || this is AsyncIdle;

  /// Executes the future provided and returns [AsyncData] with the result if successful
  /// or [AsyncError] if an exception is thrown.
  ///
  /// Supply an optional [WritableBeacon] that will be set throughout the various states.
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
  /// You can also pass the beacon as a parameter; `loading`,`data` and `error` states,
  /// as well as the last successful data will be set automatically.
  ///```dart
  ///  await AsyncValue.tryCatch(fetchUserData, beacon: beacon);
  /// ```
  ///
  /// Without `tryCatch`, handling the potential error requires more boilerplate code:
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
  }) async {
    final oldData = beacon?.peek().lastData;

    beacon?.set(AsyncLoading()..setLastData(oldData));

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

class AsyncData<T> extends AsyncValue<T> {
  final T value;

  AsyncData(this.value);

  @override
  String toString() {
    return 'AsyncData{value: $value}';
  }

  @override
  operator ==(other) => other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => toString().hashCode ^ value.hashCode;
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  final StackTrace stackTrace;

  AsyncError(this.error, this.stackTrace);

  @override
  operator ==(other) =>
      other is AsyncError<T> &&
      other.error == error &&
      other.stackTrace == stackTrace;

  @override
  int get hashCode =>
      toString().hashCode ^ error.hashCode ^ stackTrace.hashCode;
}

class AsyncLoading<T> extends AsyncValue<T> {
  @override
  operator ==(other) => other is AsyncLoading<T>;

  @override
  int get hashCode => toString().hashCode;
}

class AsyncIdle<T> extends AsyncValue<T> {
  @override
  operator ==(other) => other is AsyncIdle<T>;

  @override
  int get hashCode => toString().hashCode;
}
