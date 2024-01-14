// ignore_for_file: avoid_types_on_closure_parameters

part of '../base_beacon.dart';

/// See: Beacon.stream()
class StreamBeacon<T> extends AsyncBeacon<T> {
  /// @macro stream
  StreamBeacon(
    this._stream, {
    this.cancelOnError = false,
  }) : super(initialValue: AsyncLoading()) {
    unawaited(_init());
  }

  final Stream<T> _stream;

  /// passed to the internal stream subscription
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

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
  }

  Future<void> _init() async {
    await _subscription?.cancel();
    _subscription = _stream.listen(
      (value) {
        _setValue(AsyncData(value));
      },
      onError: (Object e, StackTrace s) {
        _setValue(AsyncError(e, s));
      },
      onDone: dispose,
      cancelOnError: cancelOnError,
    );
  }

  @override
  void dispose() {
    unsubscribe();
    _cancelAwaitedSubscription?.call();
    // ignore: inference_failure_on_function_invocation
    Awaited.remove(this);
    super.dispose();
  }
}

/// See: Beacon.rawStream()
class RawStreamBeacon<T> extends ReadableBeacon<T> {
  /// @macro rawStream
  RawStreamBeacon(
    this._stream, {
    this.cancelOnError = false,
    this.onError,
    this.onDone,
    super.initialValue,
  }) : assert(
          initialValue != null || null is T,
          'provide an initialValue or change the type parameter "$T" to "$T?"',
        ) {
    unawaited(_init());
  }

  /// called when the stream emits an error
  final Function? onError;

  /// called when the stream is done
  final Function? onDone;
  final Stream<T> _stream;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
  }

  Future<void> _init() async {
    await _subscription?.cancel();
    _subscription = _stream.listen(
      _setValue,
      onError: onError,
      onDone: () {
        // ignore: avoid_dynamic_calls
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
