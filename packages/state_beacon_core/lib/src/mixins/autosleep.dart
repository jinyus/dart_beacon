part of '../producer.dart';

mixin _AutoSleep<T, SubT> on ReadableBeacon<T> {
  /// Whether the beacon should sleep when there are no observers.
  abstract final bool shouldSleep;
  void _start();

  // cancelled by the effect dispose
  // ignore: cancel_subscriptions
  StreamSubscription<SubT>? _sub;
  VoidCallback? _effectDispose;
  var _sleeping = false;

  @override
  T peek() {
    if (_sleeping) {
      _wakeUp();
    }
    return super.peek();
  }

  @override
  T get value {
    if (_sleeping) {
      _wakeUp();
    }
    return super.value;
  }

  void _wakeUp() {
    if (_sleeping) {
      _sleeping = false;
    }
    _start();
  }

  void _goToSleep() {
    Future.delayed(Duration.zero, () {
      if (_observers.isEmpty) {
        _sleeping = true;
        _cancel();
      }
    });
  }

  void _unsubFromStream() {
    final oldSub = _sub!;
    oldSub.cancel();
    _sub = null;
  }

  @override
  void _removeObserver(Consumer observer) {
    super._removeObserver(observer);
    if (!shouldSleep) return;
    if (_observers.isEmpty) {
      _goToSleep();
    }
  }

  void _cancel() {
    _effectDispose?.call();
    _effectDispose = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
