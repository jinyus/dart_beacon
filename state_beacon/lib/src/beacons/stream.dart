part of '../base_beacon.dart';

class StreamBeacon<T> extends AsyncBeacon<T> {
  StreamBeacon(
    this._stream, {
    this.cancelOnError = false,
  }) : super(AsyncLoading()) {
    _init();
  }

  final Stream<T> _stream;
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;
  VoidCallback? _cancelAwaitedSubscription;

  @override
  Future<T> toFuture() {
    final existing = Awaited.find<T, StreamBeacon<T>>(this);
    if (existing != null) {
      return existing.future;
    }

    final newAwaited = Awaited<T, StreamBeacon<T>>(this);
    Awaited.put(this, newAwaited);

    _cancelAwaitedSubscription = newAwaited.cancel;

    return newAwaited.future;
  }

  /// resubscribes to the internal stream
  @override
  void reset() {
    _setValue(AsyncLoading());
    _init();
  }

  /// unsubscribes from the internal stream
  void unsubscribe() {
    _subscription?.cancel();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _stream.listen(
      (value) {
        _setValue(AsyncData(value));
      },
      onError: (e, s) {
        _setValue(AsyncError(e, s));
      },
      onDone: () {
        dispose();
      },
      cancelOnError: cancelOnError,
    );
  }

  @override
  void dispose() {
    unsubscribe();
    _cancelAwaitedSubscription?.call();
    Awaited.remove(this);
    super.dispose();
  }
}

class RawStreamBeacon<T> extends ReadableBeacon<T> {
  RawStreamBeacon(
    this._stream, {
    this.cancelOnError = false,
    this.onError,
    this.onDone,
    T? initialValue,
  })  : assert(initialValue != null || null is T,
            'provide an initialValue or change the type parameter "$T" to "$T?"'),
        super(initialValue) {
    _init();
  }

  final Function? onError;
  final Function? onDone;
  final Stream<T> _stream;
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// resubscribes to the internal stream
  @override
  void reset() {
    _init();
  }

  /// unsubscribes from the internal stream
  void unsubscribe() {
    _subscription?.cancel();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _stream.listen(
      (value) {
        _setValue(value);
      },
      onError: onError,
      onDone: () {
        onDone?.call();
        dispose();
      },
      cancelOnError: cancelOnError,
    );
  }

  @override
  void dispose() {
    unsubscribe();

    super.dispose();
  }
}
