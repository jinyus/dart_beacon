// ignore_for_file: public_member_api_docs

part of '../base_beacon.dart';

enum DerivedStatus { idle, running }

mixin DerivedMixin<T> on ReadableBeacon<T> {
  late VoidCallback _unsubscribe;

  // ignore: use_setters_to_change_properties
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
