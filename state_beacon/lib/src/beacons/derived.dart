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

  @override
  VoidCallback subscribe(
    void Function(T value) callback, {
    bool runImmediately = false,
  }) {
    final superUnsub =
        super.subscribe(callback, runImmediately: runImmediately);

    return () {
      superUnsub();
      // _unsubscribe(); // this should be called explicitly
    };
  }
}
