// ignore_for_file: use_if_null_to_convert_nulls_to_bools

part of '../producer.dart';

/// A callback that runs when its [Producer] changes.
class Subscription<T> implements Consumer {
  /// Creates a new [Subscription].
  Subscription(
    this.producer,
    this.fn, {
    required bool startNow,
  }) {
    if (startNow) {
      _schedule();
    } else {
      // For beacons with startNow=false, we don't schedule initially
      // but we still mark as CLEAN so future updates will work
      _status = CLEAN;
    }

    assert(() {
      BeaconObserver.instance?.onWatch(name, producer);
      return true;
    }());
  }

  /// The producer that this subscription is watching.
  final Producer<T> producer;

  /// The callback that runs when the producer changes.
  final void Function(T) fn;

  @override
  List<Producer<dynamic>?> sources = [];

  @override
  Status _status = DIRTY;

  void _schedule() {
    _effectQueue.add(this);
    _flushFn();
  }

  @override
  void updateIfNecessary() => update();

  @override
  void update() {
    if (!producer.isEmpty) {
      fn(producer.peek());
    }

    // After the update, set the status to
    // clean since we've processed the latest value.
    _status = CLEAN;
  }

  /// Disposes of the subscription.
  @override
  void dispose() {
    // Remove this subscription from the producer's observer list.
    producer._removeObserver(this);
    _effectQueue.remove(this);
  }

  @override
  void markDirty() {
    if (_status == CLEAN) {
      _status = DIRTY;
      _schedule();
    }
  }

  @override
  void _sourceDisposed(Producer<dynamic> source) {
    // if one of our sources is disposed, we should dispose ourselves
    // this is a bit strict because other sources might still be alive
    // but I want to enforce this to promote good practices
    scheduleMicrotask(dispose);
  }

  // these should never be called
  // coverage:ignore-start
  @override
  Producer<dynamic>? _producerAtIndex(int index) {
    throw UnimplementedError();
  }

  @override
  void stale(Status newStatus) => throw UnimplementedError();

  @override
  void markCheck() => throw UnimplementedError();

  @override
  void stopWatchingAllAfter(int index) {
    throw UnimplementedError();
  }

  @override
  void startWatching(Producer<dynamic> source) {
    throw UnimplementedError();
  }

  @override
  String get name => 'Subscription<${producer.name}>';
  // coverage:ignore-end
}

/// A subscription implementation specialized for [DerivedBeacon]s.
class DerivedSubscription<T> implements Consumer {
  /// Creates a new [DerivedSubscription].
  DerivedSubscription(
    this.producer,
    this.fn, {
    required this.startNow,
  }) {
    // derived beacons are lazy so they aren't registered as observers
    // of their sources until they are actually used
    //
    //re: producer._observers.isEmpty
    // If the derived beacon is already initialized and has no observers,
    // we need to schedule to ensure it gets registered properly

    // if (!producer.isEmpty && producer._observers.isEmpty){}
  }

  void _init() {
    _shouldRunRegardless = producer.isEmpty;
    if (startNow || _shouldRunRegardless) {
      _schedule();
    } else {
      // For derived beacons with startNow=false and an existing value,
      // we don't schedule initially but we still mark as CLEAN so
      // future updates will work.
      _status = CLEAN;
    }

    assert(() {
      BeaconObserver.instance?.onWatch(name, producer);
      return true;
    }());
  }

  bool _shouldRunRegardless = false;

  /// The derived beacon that this subscription is watching.
  final DerivedBeacon<T> producer;

  /// Whether the subscription should start immediately.
  final bool startNow;

  /// The callback that runs when the producer changes.
  final void Function(T) fn;

  @override
  List<Producer<dynamic>?> sources = [];

  @override
  Status _status = DIRTY;

  void _schedule() {
    _effectQueue.add(this);
    _flushFn();
  }

  @override
  void stale(Status newStatus) {
    if (_status < newStatus) {
      final oldStatus = _status;
      _status = newStatus;

      if (oldStatus == CLEAN) {
        _schedule();
      }
    }
  }

  @override
  void updateIfNecessary() {
    // Check dependent sources (only for DerivedBeacon)
    if (_status == CHECK) {
      producer.updateIfNecessary();
    }

    // Update if still dirty
    if (_status == DIRTY) {
      update();
    }

    _status = CLEAN;
  }

  @override
  void update() {
    if (_shouldRunRegardless && !startNow) {
      _shouldRunRegardless = false;
      _status = CLEAN;

      // the producer got a value before this was run
      // so we no longer need to peek() to force a value
      // this happens when .peek() is called directly
      // after the subscription is created.
      //
      // mybeacon.subscribe((_){}, startNow:false);
      // mybeacon.peek();
      if (!producer.isEmpty) return;

      producer.peek();
      _status = CLEAN;
      return;
    }

    fn(producer.peek());

    // After the update, set the status to
    // clean since we've processed the latest value.
    _status = CLEAN;
  }

  /// Disposes of the subscription.
  @override
  void dispose() {
    // Remove this subscription from the producer's observer list.
    producer._removeObserver(this);
    _effectQueue.remove(this);
  }

  @override
  void markDirty() => stale(DIRTY);

  @override
  void markCheck() => stale(CHECK);

  @override
  void _sourceDisposed(Producer<dynamic> source) {
    // if one of our sources is disposed, we should dispose ourselves
    // this is a bit strict because other sources might still be alive
    // but I want to enforce this to promote good practices
    Future.microtask(dispose);
  }

  // these should never be called
  // coverage:ignore-start
  @override
  Producer<dynamic>? _producerAtIndex(int index) {
    throw UnimplementedError();
  }

  @override
  void stopWatchingAllAfter(int index) {
    throw UnimplementedError();
  }

  @override
  void startWatching(Producer<dynamic> source) {
    throw UnimplementedError();
  }

  @override
  String get name => 'Subscription<${producer.name}>';
  // coverage:ignore-end
}
