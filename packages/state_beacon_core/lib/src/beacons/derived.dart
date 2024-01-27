// ignore_for_file: public_member_api_docs, use_setters_to_change_properties

part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

mixin DerivedMixin<T> on ReadableBeacon<T> {
  late VoidCallback _unsubscribe;
  late VoidCallback _restarter;

  void $setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
    _unsubscribe = unsubscribe;
  }

  void $setInternalEffectRestarter(VoidCallback restarter) {
    _restarter = restarter;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

// this is only used internally
class WritableDerivedBeacon<T> extends WritableBeacon<T> with DerivedMixin<T> {
  WritableDerivedBeacon({
    super.name,
    bool shouldSleep = true,
  }) {
    if (!shouldSleep) return;

    _listeners.whenEmpty(() {
      _unsubscribe();
      _sleeping = true;
    });
  }

  var _sleeping = false;

  @override
  T get value {
    if (_sleeping) {
      _restarter();
      _sleeping = false;
    }
    return super.value;
  }

  @override
  T peek() {
    if (_sleeping) {
      _restarter();
      _sleeping = false;
    }
    return super.peek();
  }
}
