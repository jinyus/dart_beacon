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

  /// Exposes this as a [Future] that can be awaited in a derived future beacon.
  /// This will trigger a re-run of the derived beacon when its state changes.
  ///
  /// var count = Beacon.writable(0);
  /// var firstName = Beacon.derivedFuture(() async => 'Sally ${count.value}');
  ///
  /// var lastName = Beacon.derivedFuture(() async => 'Smith ${count.value}');
  ///
  /// var fullName = Beacon.derivedFuture(() async {
  ///
  ///    // no need for a manual switch expression
  ///   final fnameFuture = firstName.toFuture();
  ///   final lnameFuture = lastName.toFuture();

  ///   final fname = await fnameFuture;
  ///   final lname = await lnameFuture;
  ///
  ///   return '$fname $lname';
  /// });
  Future<T> toFuture() {
    _completer ??= Beacon.writable(Completer<T>(), name: "$name's future");
    return _completer!.value.future;
  }

  /// Alias for peek().lastData.
  /// Returns the last data that was successfully loaded
  /// equivalent to `beacon.peek().lastData`
  T? get lastData => peek().lastData;

  /// If this beacon's value is [AsyncData], returns it's value.
  /// Otherwise throws an exception.
  /// equivalent to `beacon.peek().unwrap()`
  T unwrapValue() => peek().unwrap();

  /// If this beacon's value is [AsyncData], returns it's value.
  /// Otherwise returns `null`.
  /// equivalent to `beacon.peek().unwrapOrNull()`
  T? unwrapValueOrNull() => peek().unwrapOrNull();

  /// Returns `true` if this is [AsyncLoading].
  /// This is equivalent to `beacon.peek().isLoading`.
  bool get isLoading => peek().isLoading;

  /// Returns `true` if this is [AsyncIdle].
  /// This is equivalent to `beacon.peek().isIdle`.
  bool get isIdle => peek().isIdle;

  /// Returns `true` if this is [AsyncIdle] or [AsyncLoading].
  /// This is equivalent to `beacon.peek().isIdleOrLoading`.
  bool get isIdleOrLoading => peek().isIdleOrLoading;

  /// Returns `true` if this is [AsyncData].
  /// This is equivalent to `beacon.peek().isData`.
  bool get isData => peek().isData;

  /// Returns `true` if this is [AsyncError].
  /// This is equivalent to `beacon.peek().isError`.
  bool get isError => peek().isError;

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
    if (_sub != null) return;

    _effectDispose?.call();

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
            onError: (Object e, StackTrace s) {
              _setErrorWithLastData(e, s);
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
