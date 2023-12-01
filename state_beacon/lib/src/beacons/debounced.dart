part of '../base_beacon.dart';

class DebouncedBeacon<T> extends WritableBeacon<T> {
  final Duration debounceDuration;
  Timer? _debounceTimer;

  DebouncedBeacon(super.initialValue, {required Duration duration})
      : debounceDuration = duration;

  @override
  set value(T newValue) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      super.value = newValue;
    });
  }
}
