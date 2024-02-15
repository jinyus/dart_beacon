// the input type can differ from the output type
// eg: in the case of buffered beacons,
// the input type is int then the output type is List<int>

part of '../producer.dart';

/// A utility mixin for beacons that consume other beacons.
mixin BeaconWrapper<InputT, OutputT> on ReadableBeacon<OutputT> {
  final _wrapped = <int, VoidCallback>{};

  WritableBeacon<InputT>? _delegate;

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
}
