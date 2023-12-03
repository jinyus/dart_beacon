part of '../base_beacon.dart';

class ThrottledBeacon<T> extends WritableBeacon<T> {
  Duration _throttleDuration;
  bool _blocked = false;

  ThrottledBeacon(super.initialValue, {required Duration duration})
      : _throttleDuration = duration;

  void setDuration(Duration newDuration) {
    _throttleDuration = newDuration;
  }

  @override
  set value(T newValue) {
    if (_blocked) return;

    super.value = newValue;
    _blocked = true;

    Timer(_throttleDuration, () {
      _blocked = false;
    });
  }
}
