part of 'extensions.dart';

extension ListUtils<T> on List<T> {
  /// Converts a list to [ListBeacon].
  ListBeacon<T> toBeacon() {
    return ListBeacon<T>(this);
  }
}

extension StreamUtils<T> on Stream<T> {
  /// Converts a stream to [StreamBeacon].
  StreamBeacon<T> toBeacon({bool cancelOnError = false}) {
    return StreamBeacon<T>(this, cancelOnError: cancelOnError);
  }

  /// Converts a stream to [RawStreamBeacon].
  RawStreamBeacon<T> toRawBeacon({
    bool cancelOnError = false,
    Function? onError,
    Function? onDone,
    T? initialValue,
  }) {
    return RawStreamBeacon<T>(
      this,
      cancelOnError: cancelOnError,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
    );
  }
}
