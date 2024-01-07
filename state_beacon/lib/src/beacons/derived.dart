part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

mixin DerivedMixin<T> on ReadableBeacon<T> {
  late final VoidCallback _unsubscribe;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

// this is only used internally
class WritableDerivedBeacon<T> extends ReadableBeacon<T>
    with DerivedMixin<T>
    implements DerivedBeacon<T> {
  WritableDerivedBeacon({bool manualStart = false}) {
    _status = WritableBeacon(
      manualStart ? DerivedStatus.idle : DerivedStatus.running,
    );
  }

  late final WritableBeacon<DerivedStatus> _status;
  @override
  ReadableBeacon<DerivedStatus> get status => _status;

  @override
  void start() {
    if (_status.peek() != DerivedStatus.idle) {
      throw DerivedBeaconStartedTwiceException();
    }
    _status.value = DerivedStatus.running;
  }

  void $forceSet(T newValue) {
    _setValue(newValue, force: true);
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }
}

abstract class DerivedBeacon<T> extends ReadableBeacon<T> {
  /// Starts the derived beacon if `manualStart` was set to `true`.
  void start();

  /// Returns the status (`idle` or `running`) of the derived beacon.
  ReadableBeacon<DerivedStatus> get status;
}
