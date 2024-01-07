import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_beacon/src/common.dart';
import 'package:state_beacon/src/interfaces.dart';
import 'package:state_beacon/src/observer.dart';
import 'package:state_beacon/src/untracked.dart';

import 'async_value.dart';
import 'effect_closure.dart';
import 'listeners.dart';

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
part 'beacons/set.dart';
part 'beacons/map.dart';
part 'beacons/derived.dart';
part 'beacons/derived_future.dart';
part 'beacons/value_notifier.dart';
part 'beacons/awaited.dart';
part 'beacons/async.dart';

abstract class BaseBeacon<T> implements ValueListenable<T> {
  BaseBeacon([T? initialValue]) {
    if (initialValue != null || isNullable) {
      _initialValue = initialValue as T;
      _value = initialValue;
      _isEmpty = false;
    }
    BeaconObserver.instance?.onCreate(this, _isEmpty);
  }

  bool get isNullable => null is T;

  String? _debugLabel;
  String get debugLabel => _debugLabel ?? runtimeType.toString();

  void setDebugLabel(String? value) {
    _debugLabel = value;
  }

  var _isEmpty = true;
  late T _value;
  T? _previousValue;
  late final T _initialValue;
  final _listeners = Listeners();
  final List<VoidCallback> _disposeCallbacks = [];
  var _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _widgetSubscribers = <int>{};

  // coverage:ignore-start
  // requires a manual GC trigger to test
  final Finalizer<void Function()> _finalizer = Finalizer((fn) => fn());
  // coverage:ignore-end

  /// Returns the previous value without subscribing to the beacon.
  T? get previousValue => _previousValue;

  /// Returns the initial value without subscribing to the beacon.
  T get initialValue => _initialValue;

  /// Returns true if the beacon has been initialized.
  int get listenersCount => _listeners.length;

  /// Returns the current value without subscribing to the beacon.
  T peek() => _value;

  /// Equivalent to calling [value] getter.
  T call() => value;

  /// Returns the current value and subscribes to changes in the beacon
  /// when used within a [Beacon.createEffect] or [Beacon.derived].
  @override
  T get value {
    if (_isEmpty) {
      throw UninitializeLazyReadException();
    }

    if (isRunningUntracked()) {
      // if we are running untracked, we don't want to add the current effect to the listeners
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
    for (final listener in _listeners.items) {
      listener.run();
    }
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

  /// Watches a beacon and triggers a widget
  /// rebuild when its value changes.
  ///
  /// Note: must be called within a widget's build method.
  ///
  /// Usage:
  /// ```dart
  /// final counter = Beacon.writable(0);
  ///
  /// class Counter extends StatelessWidget {
  ///  const Counter({super.key});
  ///
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    final count = counter.watch(context);
  ///    return Text(count.toString());
  ///  }
  ///}
  /// ```
  T watch(BuildContext context) {
    final key = context.hashCode;

    return _watchOrObserve(
      key,
      context,
    );
  }

  /// Observes the state of a beacon and triggers a callback with the current state.
  ///
  /// The callback is provided with the current state of the beacon and a BuildContext.
  /// This can be used to show snackbars or other side effects.
  ///
  /// Usage:
  /// ```dart
  /// final exampleBeacon = Beacon.writable("Initial State");
  ///
  /// class ExampleWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     context.observe(exampleBeacon, (state, context) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text(state)),
  ///       );
  ///     });
  ///     return Container();
  ///   }
  /// }
  /// ```
  void observe(BuildContext context, ObserverCallback<T> callback) {
    final key = Object.hash(
      context,
      'isObserving', // 1 widget should only observe once
    );

    _watchOrObserve(
      key,
      context,
      callback: () => callback(previousValue as T, _value),
    );
  }

  T _watchOrObserve(
    int key,
    BuildContext context, {
    VoidCallback? callback,
  }) {
    if (_widgetSubscribers.contains(key)) {
      return _value;
    }

    _widgetSubscribers.add(key);

    final elementRef = WeakReference(context as Element);
    late VoidCallback unsub;

    rebuildWidget() {
      elementRef.target!.markNeedsBuild();
    }

    final run = callback ?? rebuildWidget;

    void handleNewValue(T value) {
      if (elementRef.target?.mounted == true) {
        run();
      } else {
        unsub();
        _widgetSubscribers.remove(key);
      }
    }

    unsub = subscribe(handleNewValue);

    // coverage:ignore-start
    // clean up if the widget is disposed
    // and value is never modified again
    _finalizer.attach(
      context,
      () {
        _widgetSubscribers.remove(key);
        unsub();
      },
      detach: context,
    );
    // coverage:ignore-end

    return _value;
  }

  /// Set the beacon to its initial value
  /// and notify all listeners
  void reset() {
    _setValue(_initialValue);
  }

  /// Registers a callback to be called when the beacon is disposed.
  void onDispose(VoidCallback callback) {
    if (isDisposed) return;

    _disposeCallbacks.add(callback);
  }

  /// Clears all registered listeners and
  /// [reset] the beacon to its initial state.
  @mustCallSuper
  void dispose() {
    _listeners.clear();
    _widgetSubscribers.clear();
    if (!_isEmpty) _value = _initialValue;
    _previousValue = null;
    _isDisposed = true;
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    BeaconObserver.instance?.onDispose(this);
  }
}
