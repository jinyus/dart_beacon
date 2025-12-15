part of '../producer.dart';

/// An immutable base class for ThrottledBeacon
mixin ReableThrottledBeacon<T> on ReadableBeacon<T> {
  bool _blocked = false;
  Duration? _duration;

  /// Whether or not this beacon is currently blocked.
  bool get isBlocked => _blocked;

  /// Sets the duration of the throttle.
  /// If [unblock] is true, the beacon will be unblocked if
  /// it is currently blocked.
  void setDuration(Duration newDuration, {bool unblock = true}) {
    _duration = newDuration;
    if (unblock) {
      _blocked = false;
    }
  }
}

/// A beacon that throttles updates to its value.
class ThrottledBeacon<T> extends WritableBeacon<T>
    with ReableThrottledBeacon<T> {
  /// @macro [ThrottledBeacon]
  ThrottledBeacon({
    Duration? duration,
    super.initialValue,
    this.dropBlocked = true,
    super.name,
  }) {
    _duration = duration;
  }

  Timer? _timer;

  /// If true, values will be dropped while the beacon is blocked.
  /// If false, values will be buffered and
  /// emitted when the beacon is unblocked.
  final bool dropBlocked;

  final List<(T, bool)> _buffer = [];

  void _processBuffer(Timer timer) {
    if (_buffer.isEmpty) {
      _timer?.cancel();
      _blocked = false;
      return;
    }

    final (bufferedValue, force) = _buffer.removeAt(0);
    _setValue(bufferedValue, force: force);
  }

  @override
  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: true);
      return;
    }

    if (_blocked) {
      if (!dropBlocked) {
        _buffer.add((newValue, force));
      }
      return;
    }

    _setValue(newValue, force: force);

    if (_duration == null) return;

    _blocked = true;
    _timer?.cancel();
    _timer = Timer.periodic(_duration!, _processBuffer);
  }

  void _cleanUp() {
    _timer?.cancel();
    _timer = null;
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
