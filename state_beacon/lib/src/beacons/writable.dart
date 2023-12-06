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
      throw WrapTargetWrongTypeException();
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
}
