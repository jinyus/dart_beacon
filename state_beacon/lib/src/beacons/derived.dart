part of '../base_beacon.dart';

class DerivedBeacon<T> extends LazyBeacon<T> {
  late final VoidCallback _unsubscribe;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  DerivedBeacon();

  void unsubscribe() {
    _unsubscribe();
  }

  void forceSetValue(T newValue) {
    setValue(newValue, force: true);
  }
}
