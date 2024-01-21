part of '../base_beacon.dart';

class ThrottledBeacon<T> extends WritableBeacon<T> {
  Duration _throttleDuration;
  Timer? _timer;
  bool _blocked = false;

  /// If true, values will be dropped while the beacon is blocked.
  /// If false, values will be buffered and emitted when the beacon is unblocked.
  final bool dropBlocked;

  final List<T> _buffer = [];

  ThrottledBeacon({
    super.initialValue,
    required Duration duration,
    this.dropBlocked = true,
    super.debugLabel,
  }) : _throttleDuration = duration;

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
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (_blocked) {
      if (!dropBlocked) {
        _buffer.add(newValue);
      }
      return;
    }

    super.set(newValue, force: force);
    _blocked = true;

    _timer?.cancel();
    _timer = Timer.periodic(_throttleDuration, (_) {
      if (_buffer.isNotEmpty) {
        T bufferedValue = _buffer.removeAt(0);
        super.set(bufferedValue, force: force);
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
  void reset() {
    _cleanUp();
    super.reset();
  }

  @override
  void dispose() {
    _cleanUp();
    super.dispose();
  }
}
