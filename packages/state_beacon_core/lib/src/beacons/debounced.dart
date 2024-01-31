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
  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: force);
      return;
    }

    if (_isEmpty) {
      _setValue(newValue, force: force);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      _setValue(newValue, force: force);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
