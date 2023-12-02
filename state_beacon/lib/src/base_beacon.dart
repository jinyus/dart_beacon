import 'dart:async';
import 'dart:math';
import 'async_value.dart';
import 'effect_closure.dart';

part 'effect.dart';
part 'exceptions.dart';
part 'beacons/debounced.dart';
part 'beacons/throttled.dart';
part 'beacons/filtered.dart';
part 'beacons/buffered.dart';
part 'beacons/timestamp.dart';
part 'beacons/lazy.dart';
part 'beacons/writable.dart';
part 'beacons/readable.dart';
part 'beacons/future.dart';
part 'beacons/stream.dart';
part 'beacons/list.dart';
part 'beacons/derived.dart';
part 'beacons/derived_future.dart';

typedef VoidCallback = void Function();
typedef Listerners = Set<EffectClosure>;

abstract class BaseBeacon<T> {
  BaseBeacon([T? initialValue]) {
    if (initialValue != null) {
      _initialValue = initialValue;
      _value = initialValue;
    }
  }

  late T _value;
  T? _previousValue;
  late final T _initialValue;
  final Listerners listeners = {};

  T? get previousValue => _previousValue;

  T get value {
    final currentEffect = _Effect.current();
    if (currentEffect != null) {
      _subscribe(currentEffect, listeners);
    }
    return _value;
  }

  void _setValue(T newValue, {bool force = false}) {
    if (_value != newValue || force) {
      _previousValue = _value;
      _value = newValue;

      if (_isRunningBatchJob()) {
        _listenersToPingAfterBatchJob.addAll(listeners);
      } else {
        _notifyListeners();
      }
    }
  }

  T peek() => _value;

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  VoidCallback subscribe(void Function(T) callback,
      {bool runImmediately = false}) {
    listener() => callback(_value);
    final effectClosure = EffectClosure(listener);
    listeners.add(effectClosure);

    if (runImmediately) {
      listener();
    }

    return () => listeners.remove(effectClosure);
  }

  void reset() {
    _setValue(_initialValue);
  }

  void _notifyListeners() {
    // We don't want to notify the current effect
    // since that would cause an infinite loop
    final currentEffect = _Effect.current();

    if (currentEffect != null) {
      if (listeners.contains(currentEffect.func)) {
        throw CircularDependencyException();
      }
    }

    // toList() is used to avoid concurrent modification
    for (final listener in listeners.toList()) {
      listener.run();
    }
  }
}
