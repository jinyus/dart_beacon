// ignore_for_file: avoid_types_on_closure_parameters

part of '../base_beacon.dart';

/// See: Beacon.stream()
class StreamBeacon<T> extends AsyncBeacon<T> {
  /// @macro stream
  StreamBeacon(
    this._stream, {
    this.cancelOnError = false,
    super.name,
  }) : super(initialValue: AsyncLoading()) {
    _init();
  }

  final Stream<T> _stream;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
  }

  void _init() {
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
    super.name,
  }) : assert(
          initialValue != null || null is T,
          'provide an initialValue or change the type parameter "$T" to "$T?"',
        ) {
    _init();
  }

  /// called when the stream emits an error
  final Function? onError;

  /// called when the stream is done
  final void Function()? onDone;
  final Stream<T> _stream;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
  }

  void _init() {
    _subscription = _stream.listen(
      _setValue,
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
