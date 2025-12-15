// ignore_for_file: use_if_null_to_convert_nulls_to_bools

part of '../producer.dart';

/// A callback that runs when its [Producer] changes.
class SyncSubscription<T> implements Consumer {
  /// Creates a new [Subscription].
  SyncSubscription(
    BeaconWrapper<dynamic, T> producer,
    this.fn, {
    required bool startNow,
  }) : _producer = producer {
    assert(() {
      BeaconObserver.instance?.onWatch(name, producer);
      return true;
    }());

    if (startNow) {
      update();
    }
  }

  /// The producer that this subscription is watching.
  BeaconWrapper<dynamic, T>? _producer;

  /// The callback that runs when the producer changes.
  final void Function(T) fn;

  @override
  List<Producer<dynamic>?> sources = [];

  @override
  Status _status = DIRTY;

  @override
  void update() {
    if (!_producer!.isEmpty) {
      fn(_producer!.peek());
    }

    if (_producer?.isDisposed == true) {
      throw Exception(
        'Beacon "$_producer" disposed in '
        'the callback. This is not permitted.',
      );
    }
  }

  /// Disposes of the subscription.
  @override
  void dispose() {
    // Remove this subscription from the producer's observer list.

    // Defer removal to the next microtask to avoid
    // modifying the list during iteration
    scheduleMicrotask(() {
      _producer?._removeObserver(this);
      _producer = null;
    });
  }

  @override
  void markDirty() => update();

  @override
  void _sourceDisposed(Producer<dynamic> source) {
    // if one of our sources is disposed, we should dispose ourselves
    // this is a bit strict because other sources might still be alive
    // but I want to enforce this to promote good practices
    dispose();
  }

  // these should never be called
  // coverage:ignore-start
  @override
  void stale(Status newStatus) => throw UnimplementedError();

  @override
  void updateIfNecessary() => throw UnimplementedError();

  @override
  void markCheck() => throw UnimplementedError();
  @override
  Producer<dynamic>? _producerAtIndex(int index) => throw UnimplementedError();

  @override
  void stopWatchingAllAfter(int index) => throw UnimplementedError();

  @override
  void startWatching(Producer<dynamic> source) => throw UnimplementedError();

  @override
  String get name => 'SyncSubscription<${_producer!.name}>';
  // coverage:ignore-end
}
