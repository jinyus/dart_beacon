part of '../producer.dart';

/// See: Beacon.stream()
class StreamBeacon<T> extends AsyncBeacon<T> {
  /// @macro stream
  StreamBeacon(
    this._compute, {
    this.cancelOnError = false,
    super.name,
    bool manualStart = false,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    if (!manualStart) start();
  }

  final Stream<T> Function() _compute;
  late VoidCallback _effectDispose;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// Starts listening to the internal stream
  /// if `manualStart` was set to true.
  ///
  /// Calling more than once has no effect
  void start() {
    if (_subscription != null) return;
    _effectDispose = Beacon.effect(
      () {
        _setLoadingWithLastData();
        _subscription = _compute().listen(
          (value) {
            _setValue(AsyncData(value));
          },
          onError: (Object e, StackTrace s) {
            _setErrorWithLastData(e, s);
          },
          cancelOnError: cancelOnError,
        );

        return () {
          _subscription!.cancel();
        };
      },
      name: name,
    );
  }

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
    _subscription = null;
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
    _effectDispose();
    super.dispose();
  }
}
