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
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  final StackTrace stackTrace;

  AsyncError(this.error, this.stackTrace);
}

class AsyncLoading<T> extends AsyncValue<T> {}

class AsyncIdle<T> extends AsyncValue<T> {}
