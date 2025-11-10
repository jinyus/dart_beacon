// ignore_for_file: use_if_null_to_convert_nulls_to_bools

part of '../producer.dart';

/// A callback that runs when its [Producer] changes.
class Subscription<T> implements Consumer {
  /// Creates a new [Subscription].
  Subscription(
    this.producer,
    this.fn, {
    required this.startNow,
    required this.synchronous,
  }) {
    // derived beacons are lazy so they aren't registered as observers
    // of their sources until they are actually used
    if (startNow || _derivedSource?.isEmpty == true) {
      _schedule();
    } else {
      _status = CLEAN;
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

  /// Whether the subscription should run synchronously.
  final bool synchronous;

  /// The callback that runs when the producer changes.
  final void Function(T) fn;

  late final DerivedBeacon<T>? _derivedSource =
      producer is DerivedBeacon ? producer as DerivedBeacon<T> : null;

  @override
  List<Producer<dynamic>?> sources = [];

  @override
  Status _status = DIRTY;

  void _schedule() {
    if (synchronous) {
      updateIfNecessary();
      return;
    }
    _effectQueue.add(this);
    _flushFn();
  }

  @override
  void stale(Status newStatus) {
    // If already dirty, no need to update the status
    if (_status == DIRTY) return;
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
      _derivedSource?.updateIfNecessary();
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
    if (!_ran && !startNow && _derivedSource?.isEmpty == true) {
      // special case for derived beacons
      // startNow is set to false but we must still run now to register the
      // the derived as an observer of its sources.
      producer.peek();
      _status = CLEAN;
      _ran = true;
      return;
    }

    _ran = true;

    // If startNow is true and producer is an empty derived. We need to peek()
    // to initialize the derived and register it as an observer of its sources.
    if (_derivedSource != null || !producer.isEmpty) fn(producer.peek());

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
