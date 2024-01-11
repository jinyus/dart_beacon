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
class WritableDerivedBeacon<T> extends ReadableBeacon<T> with DerivedMixin<T> {
  WritableDerivedBeacon();

  void $forceSet(T newValue) {
    _setValue(newValue, force: true);
  }

  @override
  void reset() {
    // noop
  }
}
