part of '../base_beacon.dart';

mixin BeaconConsumer<T, U> on BaseBeacon<U> {
  final _wrapped = <int, VoidCallback>{};

  /// Disposes all currently wrapped beacons
  void clearWrapped() {
    for (var unsub in _wrapped.values) {
      unsub();
    }
    _wrapped.clear();
  }

  /// Wrapper beacons can have different methods to set the value,
  /// so this is should be implemented by the wrapper.
  void _onNewValueFromWrapped(T value);

  // String get _label;

  // void _dispose();

  // void _onDispose(VoidCallback callback);
}

// abstract class StreamConsumer<T> {
//   void ingest<U>(
//     Stream<U> target, {
//     Function(T, U)? then,
//   });
// }
