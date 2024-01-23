part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

mixin DerivedMixin<T> on ReadableBeacon<T> {
  late VoidCallback _unsubscribe;

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
class WritableDerivedBeacon<T> extends WritableBeacon<T> with DerivedMixin<T> {
  WritableDerivedBeacon({super.name});
}
