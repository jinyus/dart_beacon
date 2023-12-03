part of '../base_beacon.dart';

class BufferedCountBeacon<T> extends WritableBeacon<List<T>> {
  final int countThreshold;
  final List<T> _buffer = [];
  final _currentBuffer = WritableBeacon<List<T>>([]);

  BufferedCountBeacon({required this.countThreshold}) : super([]);

  ReadableBeacon<List<T>> get currentBuffer => _currentBuffer;

  void add(T newValue) {
    _buffer.add(newValue);
    _currentBuffer.value = List.from(_buffer);

    if (_buffer.length == countThreshold) {
      super.value = List.from(_buffer);
      _buffer.clear();
    }
  }

  @override
  void reset() {
    currentBuffer.reset();
    super.reset();
  }
}

class BufferedTimeBeacon<T> extends WritableBeacon<List<T>> {
  final Duration duration;
  final List<T> _buffer = [];
  final _currentBuffer = WritableBeacon<List<T>>([]);
  Timer? _timer;

  BufferedTimeBeacon({required this.duration}) : super([]);

  ReadableBeacon<List<T>> get currentBuffer => _currentBuffer;

  void add(T newValue) {
    _startTimerIfNeeded();
    _buffer.add(newValue);
    _currentBuffer.value = List.from(_buffer);
  }

  void _startTimerIfNeeded() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer(duration, () {
        super.value = List.from(_buffer);
        _buffer.clear();
        _timer = null;
      });
    }
  }

  @override
  void reset() {
    currentBuffer.reset();
    _timer?.cancel();
    super.reset();
  }
}
