// ignore: lines_longer_than_80_chars
// ignore_for_file: avoid_types_on_closure_parameters, avoid_equals_and_hash_code_on_mutable_classes

part of '../base_beacon.dart';

/// See: Beacon.stream()
class StreamBeacon<T> extends AsyncBeacon<T> {
  /// @macro stream
  StreamBeacon(
    this._stream, {
    this.cancelOnError = false,
    super.name,
    bool manualStart = false,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    if (!manualStart) start();
  }

  final Stream<T> _stream;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// Starts listening to the internal stream
  /// if `manualStart` was set to true.
  ///
  /// Calling more than once has no effect
  void start() {
    if (_subscription != null) return;

    _setLoadingWithLastData();

    _subscription = _stream.listen(
      (value) {
        _setValue(AsyncData(value));
      },
      onError: (Object e, StackTrace s) {
        _setErrorWithLastData(e, s);
      },
      onDone: dispose,
      cancelOnError: cancelOnError,
    );
  }

  /// Pauses the internal stream subscription
  void pause([Future<void>? resumeSignal]) {
    _subscription?.pause(resumeSignal);
  }

  /// Resumes the internal stream subscription
  /// if it was paused.
  void resume() {
    _subscription?.resume();
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
    this.isLazy = false,
    this.cancelOnError = false,
    this.onError,
    this.onDone,
    super.initialValue,
    super.name,
  }) : assert(
          initialValue != null || null is T || isLazy,
          '''

          Do one of the following:
            1. provide an initialValue
            2. change the type parameter "$T" to "$T?"
            3. set isLazy to true (beacon must be set before it's read from)
          ''',
        ) {
    _init();
  }

  /// Whether the beacon has lazy initialization.
  final bool isLazy;

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

  @override
  int get hashCode =>
      _stream.hashCode ^
      cancelOnError.hashCode ^
      onError.hashCode ^
      onDone.hashCode ^
      (isLazy ? 1 : initialValue.hashCode) ^
      name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RawStreamBeacon && other.hashCode == hashCode;
  }
}
