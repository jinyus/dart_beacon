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
    T? initialValue,
    required Duration duration,
    this.dropBlocked = true,
  })  : _throttleDuration = duration,
        super(initialValue);

  void setDuration(Duration newDuration) {
    _throttleDuration = newDuration;
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

  @override
  void reset() {
    _timer?.cancel();
    _blocked = false;
    _buffer.clear();
    super.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blocked = false;
    _buffer.clear();
    super.dispose();
  }
}
