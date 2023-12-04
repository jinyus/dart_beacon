part of '../base_beacon.dart';

class DerivedBeacon<T> extends ReadableBeacon<T> {
  late final VoidCallback _unsubscribe;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  DerivedBeacon();

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
