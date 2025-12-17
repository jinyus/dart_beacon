// ignore_for_file: use_if_null_to_convert_nulls_to_bools

part of '../producer.dart';

/// A callback that runs when its [Producer] changes.
class Subscription<T> implements Consumer {
  /// Creates a new [Subscription].
  Subscription(
    this.producer,
    this.fn, {
    required this.startNow,
  }) {
    if (startNow) {
      _schedule();
    } else {
      // For beacons with startNow=false, we don't schedule initially
      // but we still mark as CLEAN so future updates will work
      _status = CLEAN;
      // Mark that we've already "ran" the initial update (which we're skipping)
      _ran = true;
    }

    assert(() {
      BeaconObserver.instance?.onWatch(name, producer);
      return true;
    }());
  }

  /// The producer that this subscription is watching.
  final Producer<T> producer;

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
    if (_status == DIRTY) {
      update();
      _status = CLEAN;
    }
  }

  var _ran = false;

  @override
  void update() {
    // Skip callback on first run if startNow is false
    final shouldRunCallback = _ran || startNow;

    // Track if this is the first run
    _ran = true;

    if (shouldRunCallback && !producer.isEmpty) {
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
    // If the derived beacon is already initialized and has no observers,
    // we need to schedule to ensure it gets registered properly
    if (startNow ||
        producer.isEmpty == true ||
        producer._observers.isEmpty == true) {
      _schedule();
    } else {
      // For derived beacons with startNow=false and an existing value,
      // we don't schedule initially but we still mark as CLEAN so
      // future updates will work.
      _status = CLEAN;
      // Mark that we've already "ran" the initial update (which we're skipping)
      _ran = true;
    }

    assert(() {
      BeaconObserver.instance?.onWatch(name, producer);
      return true;
    }());
  }

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
    if (_status == CLEAN) return;

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

  var _ran = false;

  @override
  void update() {
    if (!_ran && !startNow && producer.isEmpty == true) {
      // special case for derived beacons
      // startNow is set to false but we must still run now to register the
      // derived as an observer of its sources.
      producer.peek();
      _status = CLEAN;
      _ran = true;
      return;
    }

    // Skip callback on first run if startNow is false
    final shouldRunCallback = _ran || startNow;

    // Track if this is the first run
    _ran = true;

    if (shouldRunCallback) {
      // If producer is an empty derived, peek() will initialize it
      // and register it as an observer of its sources.
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
