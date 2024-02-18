part of '../producer.dart';

/// An immutable beacon.
class ReadableBeacon<T> extends Producer<T> {
  /// @macro [ReadableBeacon]
  ReadableBeacon({super.initialValue, super.name}) {
    BeaconObserver.instance?.onCreate(this, _isEmpty);
  }

  StreamController<T>? _controller;
  VoidCallback? _unsubFromSelf;

  /// Returns a broadcast [Stream] that emits the current value
  /// and all subsequent updates to the value of this beacon.
  Stream<T> get stream {
    _controller ??= StreamController<T>.broadcast(
      onListen: () {
        // if (!isEmpty) _controller!.add(peek());

        // onListen is only called when sub count goes from 0 to 1.
        // If sub count goes from 1 to 0, onCancel runs and sets _unsub to null.
        // so _unsub will always be null here but checking doesn't hurt
        _unsubFromSelf ??= subscribe(_controller!.add);
      },
      onCancel: () {
        _unsubFromSelf?.call();
        _unsubFromSelf = null;
      },
    );

    return _controller!.stream;
  }

  @override
  void _notifyListeners() {
    BeaconObserver.instance?.onUpdate(this);
    super._notifyListeners();
  }

  @override
  void dispose() {
    _unsubFromSelf?.call();
    _controller?.close();
    _controller = null;
    _unsubFromSelf = null;
    BeaconObserver.instance?.onDispose(this);
    super.dispose();
  }
}
