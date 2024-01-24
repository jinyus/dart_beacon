part of '../base_beacon.dart';

abstract class _BufferedBaseBeacon<T> extends ReadableBeacon<List<T>>
    with BeaconConsumer<T, List<T>> {
  _BufferedBaseBeacon({super.name}) : super(initialValue: []);

  final List<T> _buffer = [];

  final _currentBuffer = ListBeacon<T>([]);

  /// The current buffer of values that have been added to this beacon.
  /// This can be listened to directly.
  ReadableBeacon<List<T>> get currentBuffer => _currentBuffer;

  void addToBuffer(T newValue) {
    _buffer.add(newValue);
    _currentBuffer.add(newValue);
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

/// A beacon that exposes a buffer of values that have been added to it.
class BufferedCountBeacon<T> extends _BufferedBaseBeacon<T> {
  /// @macro [BufferedCountBeacon]
  BufferedCountBeacon({required this.countThreshold, super.name}) : super();

  /// The number of values that will be
  /// added to the buffer before it is emitted.
  final int countThreshold;

  @override
  void add(T newValue) {
    super.addToBuffer(newValue);

    if (_buffer.length == countThreshold) {
      _setValue(List.from(_buffer));
      super.clearBuffer();
    }
  }
}

/// A beacon that exposes a buffer of values that
/// have been added to it based on a timer.
class BufferedTimeBeacon<T> extends _BufferedBaseBeacon<T> {
  /// @macro [BufferedTimeBeacon]
  BufferedTimeBeacon({required this.duration, super.name}) : super();

  /// The duration to wait before emitting the buffer.
  final Duration duration;

  Timer? _timer;

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
