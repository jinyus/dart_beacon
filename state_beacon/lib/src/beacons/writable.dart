part of '../base_beacon.dart';

class WritableBeacon<T> extends ReadableBeacon<T>
    implements BeaconConsumer<WritableBeacon<T>> {
  WritableBeacon([super.initialValue]);

  final _wrapped = <int, VoidCallback>{};

  set value(T newValue) {
    set(newValue);
  }

  // Sets the value of the beacon and allows a force notification
  void set(T newValue, {bool force = false}) {
    _setValue(newValue, force: force);
  }

  @override
  WritableBeacon<T> wrap<U>(
    ReadableBeacon<U> target, {
    Function(WritableBeacon<T> p1, U p2)? then,
    bool startNow = true,
  }) {
    if (_wrapped.containsKey(target.hashCode)) return this;

    if (then == null && U != T) {
      throw WrapTargetWrongTypeException(debugLabel, target.debugLabel);
    }

    final fn = then ?? ((wb, val) => wb.set(val as T));

    final unsub = target.subscribe(
      (val) {
        fn(this, val);
      },
      startNow: startNow,
    );

    _wrapped[target.hashCode] = unsub;

    return this;
  }

  /// Disposes all currently wrapped beacons
  @override
  void clearWrapped() {
    for (var e in _wrapped.values) {
      e();
    }
    _wrapped.clear();
  }

  @override
  void dispose() {
    clearWrapped();
    super.dispose();
  }
}
