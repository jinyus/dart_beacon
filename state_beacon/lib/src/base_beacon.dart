import 'dart:async';
import 'dart:math';
import 'package:state_beacon/src/interfaces.dart';

import 'async_value.dart';
import 'effect_closure.dart';

part 'effect.dart';
part 'exceptions.dart';
part 'beacons/debounced.dart';
part 'beacons/undo_redo.dart';
part 'beacons/throttled.dart';
part 'beacons/filtered.dart';
part 'beacons/buffered.dart';
part 'beacons/timestamp.dart';
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
    if (initialValue != null || isNullable) {
      _initialValue = initialValue as T;
      _value = initialValue;
      _isEmpty = false;
    }
  }

  bool get isNullable => null is T;

  var _isEmpty = true;
  late T _value;
  T? _previousValue;
  late final T _initialValue;
  final Listerners listeners = {};

  T? get previousValue => _previousValue;

  T get value {
    if (_isEmpty) {
      throw UninitializeLazyReadException();
    }

    final currentEffect = _Effect.current();
    if (currentEffect != null) {
      _subscribe(currentEffect, listeners);
    }
    return _value;
  }

  void _notifyOrDeferBatch() {
    if (_isRunningBatchJob()) {
      _listenersToPingAfterBatchJob.addAll(listeners);
    } else {
      _notifyListeners();
    }
  }

  void _setValue(T newValue, {bool force = false}) {
    if (_isEmpty) {
      _isEmpty = false;
      _initialValue = newValue;
      _previousValue = newValue;
      _value = newValue;
      _notifyOrDeferBatch();
    } else if (_value != newValue || force) {
      _previousValue = _value;
      _value = newValue;

      _notifyOrDeferBatch();
    }
  }

  T peek() => _value;

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  VoidCallback subscribe(void Function(T) callback, {bool startNow = false}) {
    listener() => callback(_value);
    final effectClosure = EffectClosure(listener);
    listeners.add(effectClosure);

    if (startNow) {
      listener();
    }

    return () => listeners.remove(effectClosure);
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

  /// Set the beacon to its initial value
  /// and notify all listeners
  void reset() {
    _setValue(_initialValue);
  }

  /// Clears all registered listeners and
  /// [reset] the beacon to its initial state.
  void dispose() {
    listeners.clear();
    reset();
  }
}
