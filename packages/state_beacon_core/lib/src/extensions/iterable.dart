// ignore_for_file: public_member_api_docs

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
    return StreamBeacon<T>(() => this, cancelOnError: cancelOnError);
  }

  /// Converts a stream to [RawStreamBeacon].
  RawStreamBeacon<T> toRawBeacon({
    bool cancelOnError = false,
    bool isLazy = false,
    Function? onError,
    VoidCallback? onDone,
    T? initialValue,
    String? name,
  }) {
    return RawStreamBeacon<T>(
      () => this,
      cancelOnError: cancelOnError,
      isLazy: isLazy,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
      name: name,
    );
  }
}
