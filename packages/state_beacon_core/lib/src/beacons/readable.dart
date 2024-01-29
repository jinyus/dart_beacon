part of '../base_beacon.dart';

/// An immutable beacon.
class ReadableBeacon<T> extends BaseBeacon<T> {
  /// @macro [ReadableBeacon]
  ReadableBeacon({super.initialValue, super.name});

  StreamController<T>? _controller;
  VoidCallback? _unsub;

  /// Returns a broadcast [Stream] that emits the current value
  /// and all subsequent updates to the value of this beacon.
  Stream<T> get stream {
    _controller ??= StreamController<T>.broadcast(
      onListen: () {
        if (!isEmpty) _controller!.add(peek());

        // onListen is only called when sub count goes from 0 to 1.
        // If sub count goes from 1 to 0, onCancel runs and sets _unsub to null.
        // so _unsub will always be null here but checking doesn't hurt
        _unsub ??= subscribe(_controller!.add);
      },
      onCancel: () {
        _unsub?.call();
        _unsub = null;
      },
    );

    return _controller!.stream;
  }

  @override
  void dispose() {
    _unsub?.call();
    _controller?.close();
    _controller = null;
    _unsub = null;
    super.dispose();
  }
}
