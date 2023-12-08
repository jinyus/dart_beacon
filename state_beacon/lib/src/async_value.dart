// ignore_for_file: hash_and_equals

sealed class AsyncValue<T> {
  /// Casts this [AsyncValue] to [AsyncData] and return it's value
  /// or throws [CastError] if this is not [AsyncData].
  T unwrapValue() {
    return (this as AsyncData<T>).value;
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
  int get hashCode => super.hashCode ^ value.hashCode;
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
  int get hashCode => error.hashCode ^ stackTrace.hashCode;
}

class AsyncLoading<T> extends AsyncValue<T> {
  @override
  operator ==(other) => other is AsyncLoading<T>;
}

class AsyncIdle<T> extends AsyncValue<T> {
  @override
  operator ==(other) => other is AsyncIdle<T>;
}
