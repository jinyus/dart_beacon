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

  /// This records how many times loading has been set.
  /// If a compute finishes but loading has been set again since
  /// it started, we ignore the result.
  int _loadCount = 0;

  /// This stores the execution of the last call
  /// to .updateWith.
  Future<void> _updateQueue = Future.value();

  void _setLoadingWithLastData() {
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
        // If this changes after we are done computing
        // then a call to .updateWith was made so we
        // ignore our result.
        final currentUpdateWithFuture = _updateQueue;

        // this is used to invalidate any pending update
        // made via .updateWith
        _loadCount++;

        _setLoadingWithLastData();
        final stream = _compute();

        // we do this because the streamcontroller can run code onListen
        // and we don't want to track beacons accessed in that callback.
        Beacon.untracked(() {
          _sub = stream.listen(
            (v) {
              // .updateWith() was called before we finished computing
              // so we ignore this result. This is only relevant for
              // FutureBeacons.
              // nb: this is not to ignore our own stale results
              //     as that is handled by _unsubFromStream.
              if (currentUpdateWithFuture != _updateQueue) {
                return;
              }
              _setValue(AsyncData(v));
            },
            onError: (Object error, [StackTrace? stackTrace]) {
              if (currentUpdateWithFuture != _updateQueue) {
                return;
              }
              _setErrorWithLastData(error, stackTrace);
            },
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
