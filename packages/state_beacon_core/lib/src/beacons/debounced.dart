part of '../producer.dart';

/// A beacon that debounces updates to its value.
class DebouncedBeacon<T> extends WritableBeacon<T> {
  /// @macro [DebouncedBeacon]
  DebouncedBeacon({
    this.duration,
    super.initialValue,
    super.name,
  });

  /// The duration to debounce updates for.
  final Duration? duration;

  Timer? _debounceTimer;

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty || duration == null) {
      _setValue(newValue, force: force);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration!, () {
      _setValue(newValue, force: force);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
