part of '../base_beacon.dart';

class BufferedBaseBeacon<T> extends ReadableBeacon<List<T>> {
  final List<T> _buffer = [];
  final _currentBuffer = WritableBeacon<List<T>>([]);

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

  @override
  void reset() {
    currentBuffer.reset();
    super.reset();
  }
}

class BufferedCountBeacon<T> extends BufferedBaseBeacon<T> {
  final int countThreshold;

  BufferedCountBeacon({required this.countThreshold}) : super();

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
    super.clearBuffer();
    _timer?.cancel();
    super.reset();
  }
}
