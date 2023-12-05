part of '../base_beacon.dart';

class ThrottledBeacon<T> extends WritableBeacon<T> {
  Duration _throttleDuration;
  Timer? _timer;
  bool _blocked = false;

  ThrottledBeacon({T? initialValue, required Duration duration})
      : _throttleDuration = duration,
        super(initialValue);

  void setDuration(Duration newDuration) {
    _throttleDuration = newDuration;
  }

  @override
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (_blocked) return;

    super.set(newValue, force: force);
    _blocked = true;

    _timer?.cancel();
    _timer = Timer(_throttleDuration, () {
      _blocked = false;
    });
  }

  @override
  void reset() {
    _timer?.cancel();
    _blocked = false;
    super.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blocked = false;
    super.dispose();
  }
}
