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
  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: true);
      return;
    }

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
