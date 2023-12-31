part of '../base_beacon.dart';

class DebouncedBeacon<T> extends WritableBeacon<T> {
  final Duration debounceDuration;
  Timer? _debounceTimer;

  DebouncedBeacon({T? initialValue, required Duration duration})
      : debounceDuration = duration,
        super(initialValue);

  @override
  set value(T newValue) {
    set(newValue);
  }

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty) {
      super.set(newValue, force: force);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      super.set(newValue, force: force);
    });
  }
}
