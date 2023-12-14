part of '../base_beacon.dart';

abstract class BufferedBaseBeacon<T> extends ReadableBeacon<List<T>>
    implements BeaconConsumer<BufferedBaseBeacon<T>> {
  final List<T> _buffer = [];
  final _currentBuffer = WritableBeacon<List<T>>([]);
  final _wrapped = <int, VoidCallback>{};

  BufferedBaseBeacon() : super([]);

  ReadableBeacon<List<T>> get currentBuffer => _currentBuffer;

  void addToBuffer(T newValue) {
    _buffer.add(newValue);
    _currentBuffer.value = List.from(_buffer);
  }

  void clearBuffer() {
    _buffer.clear();
    _currentBuffer.reset();
  }

  void add(T newValue);

  @override
  void reset() {
    clearBuffer();
    super.reset();
  }

  @override
  BufferedBaseBeacon<T> wrap<U>(
    ReadableBeacon<U> target, {
    Function(BufferedBaseBeacon<T> p1, U p2)? then,
    bool startNow = true,
  }) {
    if (_wrapped.containsKey(target.hashCode)) return this;

    if (then == null && U != T) {
      throw WrapTargetWrongTypeException();
    }

    final fn = then ?? ((b, val) => b.add(val as T));

    final unsub = target.subscribe((val) {
      fn(this, val);
    }, startNow: startNow);

    _wrapped[target.hashCode] = unsub;

    return this;
  }

  /// Disposes all currently wrapped beacons
  @override
  void clearWrapped() {
    for (var e in _wrapped.values) {
      e();
    }
    _wrapped.clear();
  }

  @override
  void dispose() {
    clearWrapped();
    clearBuffer();
    super.dispose();
  }
}

class BufferedCountBeacon<T> extends BufferedBaseBeacon<T> {
  final int countThreshold;

  BufferedCountBeacon({required this.countThreshold}) : super();

  @override
  void add(T newValue) {
    super.addToBuffer(newValue);

    if (_buffer.length == countThreshold) {
      _setValue(List.from(_buffer));
      super.clearBuffer();
    }
  }
}

class BufferedTimeBeacon<T> extends BufferedBaseBeacon<T> {
  final Duration duration;
  Timer? _timer;

  BufferedTimeBeacon({required this.duration}) : super();

  @override
  void add(T newValue) {
    super.addToBuffer(newValue);
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer(duration, () {
        _setValue(List.from(_buffer));
        super.clearBuffer();
        _timer = null;
      });
    }
  }

  @override
  void reset() {
    _timer?.cancel();
    super.reset();
  }
}
