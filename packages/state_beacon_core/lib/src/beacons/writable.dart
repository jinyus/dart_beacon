part of '../base_beacon.dart';

/// A beacon that can be written to.
class WritableBeacon<T> extends ReadableBeacon<T> with BeaconConsumer<T, T> {
  /// @macro [WritableBeacon]
  WritableBeacon({super.initialValue, super.name});

  set value(T newValue) {
    set(newValue);
  }

  /// Set the beacon to its initial value
  /// and notify all listeners
  void reset() {
    _setValue(_initialValue);
  }

  /// Sets the value of the beacon and allows a force notification
  void set(T newValue, {bool force = false}) {
    _setValue(newValue, force: force);
  }

  @override
  void dispose() {
    clearWrapped();
    super.dispose();
  }

  // FOR BEACON CONSUMER MIXIN

  @override
  void _onNewValueFromWrapped(T value) {
    set(value);
  }
}
