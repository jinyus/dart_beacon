part of '../producer.dart';

/// A beacon that debounces updates to its value.
class DebouncedBeacon<T> extends WritableBeacon<T> {
  /// @macro [DebouncedBeacon]
  DebouncedBeacon({
    this.duration,
    super.initialValue,
    super.name,
    bool allowFirst = false,
  }) : _allowFirst = allowFirst;

  final bool _allowFirst;

  /// The duration to debounce updates for.
  final Duration? duration;

  Timer? _debounceTimer;

  @override
  void set(T newValue, {bool force = false}) {
    if (duration == null || (_isEmpty && _allowFirst)) {
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
