part of '../producer.dart';

/// A beacon that can be written to.
class WritableBeacon<T> extends ReadableBeacon<T> with BeaconWrapper<T, T> {
  /// @macro [WritableBeacon]
  WritableBeacon({super.initialValue, super.name});

  set value(T newValue) {
    set(newValue);
  }

  /// Set the beacon to its initial value
  /// and notify all listeners
  @override
  void reset({bool force = false}) {
    if (_isEmpty) return;

    if (_delegate != null) {
      _delegate!.reset(force: force);
      // return;
    }

    _setValue(_initialValue, force: force);
  }

  /// Sets the value of the beacon and allows a force notification
  @override
  void set(T newValue, {bool force = false}) {
    _internalSet(newValue, force: force, delegated: true);
  }

  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    _setValue(newValue, force: force);
  }

  @override
  void dispose() {
    _delegate = null;
    clearWrapped();
    super.dispose();
  }

  // FOR BEACON WRAPPER MIXIN

  @override
  void _onNewValueFromWrapped(T value) {
    _internalSet(value, force: true);
  }
}
