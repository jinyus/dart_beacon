part of '../base_beacon.dart';

class StreamBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  StreamBeacon(this._stream) : super(AsyncLoading()) {
    _init();
  }

  final Stream<T> _stream;

  StreamSubscription<T>? _subscription;

  /// Resets the signal by calling the [Stream] again
  @override
  void reset() {
    // noop
  }

  void unsubscribe() {
    _subscription?.cancel();
  }

  void _init() {
    if (peek() is! AsyncLoading) {
      _setValue(AsyncLoading());
    }

    _subscription = _stream.listen((value) {
      _setValue(AsyncData(value));
    });

    _subscription!.onError((e, s) {
      _setValue(AsyncError(e, s));
    });
  }
}
