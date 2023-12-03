part of '../base_beacon.dart';

class BufferedCountBeacon<T> extends WritableBeacon<List<T>> {
  final int countThreshold;
  final List<T> _buffer = [];

  BufferedCountBeacon({required this.countThreshold}) : super([]);

  int get bufferedCount => _buffer.length;

  void add(T newValue) {
    _buffer.add(newValue);
    if (_buffer.length == countThreshold) {
      super.value = List.from(_buffer);
      _buffer.clear();
    }
  }
}

class BufferedTimeBeacon<T> extends WritableBeacon<List<T>> {
  final Duration duration;
  final List<T> _buffer = [];
  Timer? _timer;

  BufferedTimeBeacon({required this.duration}) : super([]);

  int get bufferedCount => _buffer.length;

  void add(T newValue) {
    _startTimerIfNeeded();
    _buffer.add(newValue);
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
}
