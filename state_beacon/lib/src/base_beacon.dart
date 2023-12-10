import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:state_beacon/src/common.dart';
import 'package:state_beacon/src/interfaces.dart';
import 'package:state_beacon/src/untracked.dart';

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
part 'beacons/value_notifier.dart';
part 'beacons/awaited.dart';

abstract class BaseBeacon<T> implements ValueListenable<T> {
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
  final Listerners _listeners = {};

  T? get previousValue => _previousValue;
  T get initialValue => _initialValue;
  int get listenersCount => _listeners.length;

  @override
  T get value {
    if (_isEmpty) {
      throw UninitializeLazyReadException();
    }
    if (isRunningUntracked()) {
      return _value;
    }

    final currentEffect = _Effect.current();
    if (currentEffect != null) {
      _subscribe(currentEffect, _listeners);
    }
    return _value;
  }

  void _notifyOrDeferBatch() {
    if (isRunningUntracked()) {
      return;
    } else if (_isRunningBatchJob()) {
      _listenersToPingAfterBatchJob.addAll(_listeners);
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
    _listeners.add(effectClosure);

    if (startNow) {
      listener();
    }

    return () => _listeners.remove(effectClosure);
  }

  void _notifyListeners() {
    // We don't want to notify the current effect
    // since that would cause an infinite loop
    final currentEffect = _Effect.current();

    if (currentEffect != null) {
      if (_listeners.contains(currentEffect.func)) {
        throw CircularDependencyException();
      }
    }

    // toList() is used to avoid concurrent modification
    for (final listener in _listeners.toList()) {
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
    _listeners.clear();
    if (!_isEmpty) _value = _initialValue;
    _previousValue = null;
  }

  @override
  void addListener(VoidCallback listener) {
    final effectClosure = EffectClosure(listener, customID: listener.hashCode);

    _listeners.add(effectClosure);
  }

  @override
  void removeListener(VoidCallback listener) {
    final effectClosure = EffectClosure(listener, customID: listener.hashCode);
    _listeners.remove(effectClosure);
  }
}
