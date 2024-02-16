part of '../producer.dart';

/// A beacon that exposes an [AsyncValue].
abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  /// @macro [AsyncBeacon]
  AsyncBeacon(
    this._compute, {
    super.name,
    this.cancelOnError = false,
    bool manualStart = false,
  }) : super(initialValue: manualStart ? AsyncIdle() : AsyncLoading()) {
    _isEmpty = false;

    if (!manualStart) start();
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

  /// Casts its value to [AsyncData] and return
  /// it's value or throws `CastError` if this is not [AsyncData].
  /// equivalent to `beacon.peek().unwrap()`
  T unwrapValue() => peek().unwrap();

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
    _setValue(AsyncLoading()..setLastData(lastData));
  }

  void _setErrorWithLastData(Object error, [StackTrace? stackTrace]) {
    _setValue(AsyncError(error, stackTrace)..setLastData(lastData));
  }

  Stream<T> Function() _compute;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  // cancelled in the effect cleanup
  // ignore: cancel_subscriptions
  StreamSubscription<T>? _sub;
  VoidCallback? _effectDispose;

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
  void start() {
    if (_sub != null) return;
    _effectDispose = Beacon.effect(
      () {
        _setLoadingWithLastData();
        _sub = _compute().listen(
          (value) {
            _setValue(AsyncData(value));
          },
          onError: (Object e, StackTrace s) {
            _setErrorWithLastData(e, s);
          },
          cancelOnError: cancelOnError,
        );

        return () {
          final oldSub = _sub!;
          oldSub.cancel();
        };
      },
      name: name,
    );
  }

  void _cancel() {
    _effectDispose?.call();
    _effectDispose = null;
    _sub = null;
  }

  @override
  void dispose() {
    _cancel();
    _completer?.dispose();
    _completer = null;
    super.dispose();
  }
}
