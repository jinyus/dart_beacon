part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

class DerivedBeaconBase<T> extends ReadableBeacon<T> {
  late final VoidCallback _unsubscribe;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  DerivedBeaconBase();

  void unsubscribe() {
    _unsubscribe();
  }

  void forceSetValue(T newValue) {
    _setValue(newValue, force: true);
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

class DerivedBeacon<T> extends DerivedBeaconBase<T> {
  DerivedBeacon({bool startNow = true}) {
    _status = WritableBeacon(
      startNow ? DerivedStatus.running : DerivedStatus.idle,
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
