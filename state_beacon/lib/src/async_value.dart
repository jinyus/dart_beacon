sealed class AsyncValue<T> {}

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
