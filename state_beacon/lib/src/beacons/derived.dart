part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

mixin DerivedMixin<T> on ReadableBeacon<T> {
  late final VoidCallback _unsubscribe;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  void forceSetValue(T newValue) {
    _setValue(newValue, force: true);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

class DerivedBeacon<T> extends ReadableBeacon<T> with DerivedMixin<T> {
  DerivedBeacon({bool manualStart = false}) {
    _status = WritableBeacon(
      manualStart ? DerivedStatus.idle : DerivedStatus.running,
    );
  }

  late final WritableBeacon<DerivedStatus> _status;
  ReadableBeacon<DerivedStatus> get status => _status;

  void start() {
    if (_status.peek() != DerivedStatus.idle) {
      throw DerivedBeaconStartedTwiceException();
    }
    _status.value = DerivedStatus.running;
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }
}
