import 'dart:async';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:state_beacon_core/src/common.dart';
import 'package:state_beacon_core/src/untracked.dart';

import 'async_value.dart';
import 'effect_closure.dart';
import 'listeners.dart';
import 'observer.dart';
import 'state_beacon.dart';

part 'effect.dart';
part 'batch.dart';
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
part 'beacons/set.dart';
part 'beacons/map.dart';
part 'beacons/derived.dart';
part 'beacons/derived_future.dart';
part 'beacons/awaited.dart';
part 'beacons/async.dart';
part 'extensions/wrap.dart';
part 'extensions/wrap_utils.dart';
part 'mixins/beacon_consumer.dart';

/// The base class for all beacons.
abstract class BaseBeacon<T> {
  /// @macro [BaseBeacon]
  BaseBeacon({T? initialValue, String? name}) : _name = name {
    if (initialValue != null || _isNullable) {
      _initialValue = initialValue as T;
      _value = initialValue;
      _isEmpty = false;
    }

    BeaconObserver.instance?.onCreate(this, _isEmpty);
  }

  bool get _isNullable => null is T;

  final String? _name;

  /// Returns the name of the beacon.
  /// This can be used for logging/observability
  String get name => _name ?? runtimeType.toString();

  var _isEmpty = true;

  /// Returns true if the beacon has not been initialized.
  /// This is only relevant for lazy beacons.
  bool get isEmpty => _isEmpty;

  late T _value;
  T? _previousValue;
  late final T _initialValue;
  final _listeners = Listeners();
  final List<VoidCallback> _disposeCallbacks = [];
  var _isDisposed = false;

  /// Returns true if the beacon has been disposed.
  bool get isDisposed => _isDisposed;

  /// The hashcode of all widgets subscribed to this beacon.
  /// This should not be used directly.
  @protected
  final widgetSubscribers = <int>{};

  /// Returns the previous value without subscribing to the beacon.
  T? get previousValue => _previousValue;

  /// Returns the initial value without subscribing to the beacon.
  T get initialValue => _initialValue;

  /// Returns the number of listeners currently subscribed to this beacon.
  int get listenersCount => _listeners.length;

  /// Returns the current value without subscribing to the beacon.
  T peek() => _value;

  /// Equivalent to calling [value] getter.
  T call() => value;

  /// Returns the current value and subscribes to changes in the beacon
  /// when used within a [Beacon.effect] or [Beacon.derived].
  T get value {
    if (_isEmpty) {
      throw UninitializeLazyReadException(name);
    }

    if (isRunningUntracked()) {
      // if we are running untracked, we don't want
      // to add the current effect to the listeners
      return _value;
    }

    final currentEffect = _Effect.current();
    if (currentEffect != null) {
      currentEffect._startWatching(this);
    }
    return _value;
  }

  void _notifyOrDeferBatch() {
    if (isRunningUntracked()) {
      final currentEffects = <EffectClosure>[];
      for (final effect in _effectStack) {
        _listeners.remove(effect.func);
        currentEffects.add(effect.func);
      }
      reAddListeners = () {
        _listeners.addAll(currentEffects);
      };
    }

    if (_isRunningBatchJob()) {
      _listenersToPingAfterBatchJob.addAll(_listeners.items);
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
      BeaconObserver.instance?.onUpdate(this);
      _notifyOrDeferBatch();
    } else if (_value != newValue || force) {
      _previousValue = _value;
      _value = newValue;

      BeaconObserver.instance?.onUpdate(this);
      _notifyOrDeferBatch();
    }
  }

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  VoidCallback subscribe(void Function(T) callback, {bool startNow = false}) {
    void listener() => callback(_value);
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
        throw CircularDependencyException(name);
      }
    }

    // toList() is used to avoid concurrent modification
    for (final listener in _listeners.items) {
      // ignore: avoid_dynamic_calls
      listener.run();
    }
  }

  /// Registers a callback to be called when the beacon is disposed.
  void onDispose(VoidCallback callback) {
    if (isDisposed) return;

    _disposeCallbacks.add(callback);
  }

  /// Clears all registered listeners and
  /// reset the beacon to its initial state.
  void dispose() {
    _listeners.clear();
    widgetSubscribers.clear();
    if (!_isEmpty) _value = _initialValue;
    _previousValue = null;
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    _isDisposed = true;
    BeaconObserver.instance?.onDispose(this);
  }

  @override
  String toString() => '$name(${_isEmpty ? 'uninitialized' : _value})';
}
