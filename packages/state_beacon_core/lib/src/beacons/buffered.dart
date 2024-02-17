// ignore_for_file: lines_longer_than_80_chars

part of '../producer.dart';

/// Base class for buffered beacons.
abstract class BufferedBaseBeacon<T> extends ReadableBeacon<List<T>>
    with BeaconWrapper<T, List<T>> {
  // ignore: public_member_api_docs
  BufferedBaseBeacon({super.name}) : super(initialValue: []);

  final List<T> _buffer = [];

  late final _currentBuffer = ListBeacon<T>([], name: "$name's currentBuffer");

  /// The current buffer of values that have been added to this beacon.
  /// This can be listened to directly.
  ReadableBeacon<List<T>> get currentBuffer => _currentBuffer;

  void _addToBuffer(T newValue) {
    _buffer.add(newValue);
    _currentBuffer.add(newValue);
  }

  void _clearBuffer() {
    _buffer.clear();
    _currentBuffer.reset();
  }

  /// Adds a new value to the buffer.
  void add(T newValue) {
    _internalAdd(newValue, delegated: true);
  }

  void _internalAdd(T newValue, {bool delegated = false});

  /// Clears the buffer
  @override
  void reset({bool force = false}) {
    _clearBuffer();
    _setValue(_initialValue, force: force);

    // we clear the buffer first because the delegate will
    // add its own initial value back to the buffer
    if (_delegate != null) {
      _delegate!.reset(force: force);
    }
  }

  @override
  void dispose() {
    clearWrapped();
    _clearBuffer();
    _currentBuffer.dispose();
    super.dispose();
  }

  // FOR BEACON CONSUMER MIXIN

  @override
  void _onNewValueFromWrapped(T value) {
    _internalAdd(value);
  }
}

/// A beacon that exposes a buffer of values that have been added to it.
class BufferedCountBeacon<T> extends BufferedBaseBeacon<T> {
  /// @macro [BufferedCountBeacon]
  BufferedCountBeacon({required this.countThreshold, super.name}) : super();

  /// The number of values that will be
  /// added to the buffer before it is emitted.
  final int countThreshold;

  @override
  void _internalAdd(T newValue, {bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: true);
      return;
    }
    super._addToBuffer(newValue);

    if (_buffer.length == countThreshold) {
      _setValue(List.from(_buffer));
      super._clearBuffer();
    }
  }
}

/// A beacon that exposes a buffer of values that
/// have been added to it based on a timer.
class BufferedTimeBeacon<T> extends BufferedBaseBeacon<T> {
  /// @macro [BufferedTimeBeacon]
  BufferedTimeBeacon({required this.duration, super.name}) : super();

  /// The duration to wait before emitting the buffer.
  final Duration duration;

  Timer? _timer;

  @override
  void _internalAdd(T newValue, {bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: true);
      return;
    }

    super._addToBuffer(newValue);
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer(duration, () {
        _setValue(List.from(_buffer));
        super._clearBuffer();
        _timer = null;
      });
    }
  }

  @override
  void reset({bool force = false}) {
    _timer?.cancel();
    super.reset(force: force);
  }
}
