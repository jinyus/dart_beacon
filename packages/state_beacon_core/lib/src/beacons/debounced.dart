part of '../base_beacon.dart';

/// A beacon that debounces updates to its value.
class DebouncedBeacon<T> extends WritableBeacon<T> {
  /// @macro [DebouncedBeacon]
  DebouncedBeacon({
    required Duration duration,
    super.initialValue,
    super.name,
  }) : debounceDuration = duration;

  /// The duration to debounce updates for.
  final Duration debounceDuration;

  Timer? _debounceTimer;

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
