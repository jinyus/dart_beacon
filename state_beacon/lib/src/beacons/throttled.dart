part of '../base_beacon.dart';

class ThrottledBeacon<T> extends WritableBeacon<T> {
  final Duration throttleDuration;
  bool _blocked = false;

  ThrottledBeacon(super.initialValue, {required Duration duration})
      : throttleDuration = duration;

  @override
  set value(T newValue) {
    if (_blocked) return;

    super.value = newValue;
    _blocked = true;

    Timer(throttleDuration, () {
      _blocked = false;
    });
  }
}
