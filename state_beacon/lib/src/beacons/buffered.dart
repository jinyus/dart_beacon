part of '../base_beacon.dart';

abstract class BufferedBaseBeacon<T> extends ReadableBeacon<List<T>>
    with BeaconConsumer<T, List<T>> {
  final List<T> _buffer = [];
  final _currentBuffer = WritableBeacon<List<T>>(initialValue: []);

  BufferedBaseBeacon({super.debugLabel}) : super(initialValue: []);

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

  /// Clears the buffer
  void reset() {
    clearBuffer();
    _setValue(_initialValue);
  }

  @override
  void dispose() {
    clearWrapped();
    clearBuffer();
    _currentBuffer.dispose();
    super.dispose();
  }

  // FOR BEACON CONSUMER MIXIN

  @override
  void _onNewValueFromWrapped(T value) {
    add(value);
  }
}

class BufferedCountBeacon<T> extends BufferedBaseBeacon<T> {
  final int countThreshold;

  BufferedCountBeacon({required this.countThreshold, super.debugLabel})
      : super();

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

  BufferedTimeBeacon({required this.duration, super.debugLabel}) : super();

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
