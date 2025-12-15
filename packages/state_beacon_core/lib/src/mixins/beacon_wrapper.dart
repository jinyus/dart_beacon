// the input type can differ from the output type
// eg: in the case of buffered beacons,
// the input type is int then the output type is List<int>

part of '../producer.dart';

/// A utility mixin for beacons that consume other beacons.
mixin BeaconWrapper<InputT, OutputT> on ReadableBeacon<OutputT> {
  final _wrapped = <int, VoidCallback>{};

  /// Disposes all currently wrapped beacons
  void clearWrapped() {
    for (final unsub in _wrapped.values) {
      unsub();
    }
    _wrapped.clear();
  }

  /// Wrapper beacons can have different methods to set the value,
  /// so this is should be implemented by the wrapper.
  void _onNewValueFromWrapped(InputT value);

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  ///
  /// This disables automatic batching is not recommended for
  /// most usecases. Use [subscribe] if you are unsure.
  ///
  /// If [startNow] is true, the callback will be called immediately
  /// with the current value of the beacon.
  VoidCallback subscribeSynchronously(
    void Function(OutputT) callback, {
    bool startNow = true,
  }) {
    assert(!_isDisposed, 'Cannot subscribe to a disposed beacon.');
    final sub = SyncSubscription(
      this,
      callback,
      startNow: startNow,
    );
    _observers.add(sub);
    return sub.dispose;
  }
}
