sealed class AsyncValue<T> {
  /// Casts this [AsyncValue] to [AsyncData] and return it's value
  /// or throws [CastError] if this is not [AsyncData].
  T unwrapValue() {
    return (this as AsyncData<T>).value;
  }

  /// Executes the future provided and returns `AsyncData` with the result if successful
  /// or `AsyncError` if the future throws an exception.
  /// /// Example:
  /// ```dart
  /// Future<String> fetchUserData() {
  ///   // Imagine this is a network request that might throw an error
  ///   return Future.delayed(Duration(seconds: 1), () => 'User data');
  /// }
  ///
  ///   beacon.value = AsyncLoading();
  ///   beacon.value = await AsyncValue.tryCatch(fetchUserData);
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
  /// }
  /// ```
  static Future<AsyncValue<T>> tryCatch<T>(Future<T> Function() future) async {
    try {
      return AsyncData(await future());
    } catch (e, s) {
      return AsyncError(e, s);
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
