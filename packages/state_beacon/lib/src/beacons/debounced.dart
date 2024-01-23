part of '../base_beacon.dart';

class DebouncedBeacon<T> extends WritableBeacon<T> {
  final Duration debounceDuration;
  Timer? _debounceTimer;

  DebouncedBeacon({
    super.initialValue,
    required Duration duration,
    super.debugLabel,
  }) : debounceDuration = duration;

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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
