part of '../producer.dart';

/// A beacon that exposes an [AsyncValue].
abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>>
    with _AutoSleep<AsyncValue<T>, T> {
  /// @macro [AsyncBeacon]
  AsyncBeacon(
    this._compute, {
    required this.shouldSleep,
    super.name,
    this.cancelOnError = false,
    bool manualStart = false,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    _isEmpty = false;

    if (!manualStart) _start();
  }

  void _setLoadingWithLastData() {
    if (isLoading) return;
    _setValue(AsyncLoading()..setLastData(lastData));
  }

  void _setErrorWithLastData(Object error, [StackTrace? stackTrace]) {
    _setValue(AsyncError(error, stackTrace)..setLastData(lastData));
  }

  Stream<T> Function() _compute;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  /// Whether the beacon should sleep when there are no observers.
  @override
  final bool shouldSleep;

  WritableBeacon<Completer<T>>? _completer;

  @override
  void _setValue(AsyncValue<T> newValue, {bool force = false}) {
    if (_completer != null) {
      final compl = _completer!;

      if (compl.peek().isCompleted) {
        compl._setValue(Completer<T>());
      }

      if (newValue case final AsyncData<T> data) {
        compl.peek().complete(data.value);
      } else if (newValue case AsyncError(:final error, :final stackTrace)) {
        compl.peek().completeError(error, stackTrace);
      }
    }

    super._setValue(newValue, force: force);
  }

  /// Starts listening to the internal stream
  /// if `manualStart` was set to true.
  ///
  /// Calling more than once has no effect
  void start() => _start();

  @override
  void _start() {
    if (_effectDispose != null) return;

    // needs to be in loading state instantly when waking up
    // so beacon.value.isLoading is true
    // even though this is called in the effect, it's asynchronous
    // so it doesn't happen instantly
    _setLoadingWithLastData();

    _effectDispose = Beacon.effect(
      () {
        _setLoadingWithLastData();
        final stream = _compute();

        // we do this because the streamcontroller can run code onListen
        // and we don't want to track beacons accessed in that callback.
        Beacon.untracked(() {
          _sub = stream.listen(
            (v) => _setValue(AsyncData(v)),
            onError: _setErrorWithLastData,
            cancelOnError: cancelOnError,
          );
        });

        return _unsubFromStream;
      },
      name: name,
    );
  }

  @override
  void dispose() {
    _cancel();
    _completer?.dispose();
    _completer = null;
    super.dispose();
  }
}
