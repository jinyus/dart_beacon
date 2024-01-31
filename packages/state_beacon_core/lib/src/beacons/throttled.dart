part of '../base_beacon.dart';

/// A beacon that throttles updates to its value.
class ThrottledBeacon<T> extends WritableBeacon<T> {
  /// @macro [ThrottledBeacon]
  ThrottledBeacon({
    required Duration duration,
    super.initialValue,
    this.dropBlocked = true,
    super.name,
  }) : _throttleDuration = duration;

  Duration _throttleDuration;
  Timer? _timer;
  bool _blocked = false;

  /// If true, values will be dropped while the beacon is blocked.
  /// If false, values will be buffered and
  /// emitted when the beacon is unblocked.
  final bool dropBlocked;

  final List<T> _buffer = [];

  /// Whether or not this beacon is currently blocked.
  bool get isBlocked => _blocked;

  /// Sets the duration of the throttle.
  /// If [unblock] is true, the beacon will be unblocked if
  /// it is currently blocked.
  void setDuration(Duration newDuration, {bool unblock = true}) {
    _throttleDuration = newDuration;
    if (unblock) {
      _blocked = false;
    }
  }

  @override
  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: force);
      return;
    }

    if (_blocked) {
      if (!dropBlocked) {
        _buffer.add(newValue);
      }
      return;
    }

    _setValue(newValue, force: force);
    _blocked = true;

    _timer?.cancel();
    _timer = Timer.periodic(_throttleDuration, (_) {
      if (_buffer.isNotEmpty) {
        final bufferedValue = _buffer.removeAt(0);
        _setValue(bufferedValue, force: force);
      } else {
        _timer?.cancel();
        _blocked = false;
      }
    });
  }

  void _cleanUp() {
    _timer?.cancel();
    _blocked = false;
    _buffer.clear();
  }

  @override
  void reset({bool force = false}) {
    _cleanUp();
    super.reset(force: force);
  }

  @override
  void dispose() {
    _cleanUp();
    super.dispose();
  }
}
