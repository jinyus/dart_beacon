// ignore_for_file: lines_longer_than_80_chars

// Nodes for constructing a reactive graph of reactive values and reactive computations.
// The graph is acyclic.
// The user inputs new values into the graph by calling set() on one more more reactive nodes.
// The user retrieves computed results from the graph by calling get() on one or more reactive nodes.
// The library is responsible for running any necessary reactive computations so that get() is
// up to date with all prior set() calls anywhere in the graph.
//
// We call input nodes 'roots' and the output nodes 'leaves' of the graph here in discussion,
// but the distinction is based on the use of the graph, all nodes have the same internal structure.
// Changes flow from roots to leaves. It would be effective but inefficient to immediately propagate
// all changes from a root through the graph to descendant leaves. Instead we defer change
// most change progogation computation until a leaf is accessed. This allows us to coalesce computations
// and skip altogether recalculating unused sections of the graph.
//
// Each reactive node tracks its sources and its observers (observers are other
// elements that have this node as a source). Source and observer links are updated automatically
// as observer reactive computations re-evaluate and call get() on their sources.
//
// Each node stores a cache state to support the change propogation algorithm: 'clean', 'check', or 'dirty'
// In general, execution proceeds in three passes:
//  1. set() propogates changes down the graph to the leaves
//     direct children are marked as dirty and their deeper descendants marked as check
//     (no reactive computations are evaluated)
//  2. get() requests that parent nodes updateIfNecessary(), which proceeds recursively up the tree
//     to decide whether the node is clean (parents unchanged) or dirty (parents changed)
//  3. updateIfNecessary() evaluates the reactive computation if the node is dirty
//     (the computations are executed in root to leaf order)

// current capture context for identifying @reactive sources (other reactive elements) and cleanups
// - active while evaluating a reactive function body

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:basic_interfaces/basic_interfaces.dart';
import 'package:state_beacon_core/src/common/exceptions.dart';
import 'package:state_beacon_core/src/creator/creator.dart';

import 'common/async_value.dart';
import 'common/types.dart';
import 'extensions/extensions.dart';
import 'observer.dart';

part 'beacons/async.dart';
part 'beacons/buffered.dart';
part 'beacons/debounced.dart';
part 'beacons/derived.dart';
part 'beacons/family.dart';
part 'beacons/filtered.dart';
part 'beacons/mapped.dart';
part 'beacons/future.dart';
part 'beacons/list.dart';
part 'beacons/map.dart';
part 'beacons/readable.dart';
part 'beacons/set.dart';
part 'beacons/stream.dart';
part 'beacons/stream_raw.dart';
part 'beacons/throttled.dart';
part 'beacons/timestamp.dart';
part 'beacons/undo_redo.dart';
part 'beacons/writable.dart';
part 'beacons/periodic.dart';
part 'consumer.dart';
part 'consumers/effect.dart';
part 'consumers/subscription.dart';
part 'extensions/chain.dart';
part 'extensions/wrap.dart';
part 'mixins/beacon_wrapper.dart';
part 'mixins/autosleep.dart';
part 'scheduler.dart';
part 'untracked.dart';

/// The current consumer.
Consumer? currentConsumer;

/// The current list of producers accessed when evaluating a reactive function.
List<Producer<dynamic>?> currentGets = [];

/// The current index of this producer in the consumer's list of producers.
int currentGetsIndex = 0;

/// The base class for all beacons.
abstract class Producer<T> implements Disposable {
  /// Creates a new [Producer].
  Producer({T? initialValue, String? name})
      : _name = name,
        _observers = [] {
    if (initialValue != null || _isNullable) {
      _initialValue = initialValue as T;
      _value = initialValue;
      _isEmpty = false;
    }
  }

  /// This is true if the beacon is guarded from being disposed by
  /// its dependants.
  bool _guarded = false;

  /// This is true if the producer is a DerivedBeacon.
  /// Used to avoid type checks in hot paths.
  bool get _isDerived => false;

  /// Prevents the beacon from being disposed by its dependants.
  /// The beacon will still be disposed if its dependencies are disposed.
  ///
  /// ```dart
  /// final number = Beacon(0)..guard();
  /// final doubled = number.map((value) => value * 2);
  /// doubled.dispose();
  /// number.disposed; // false
  /// ```
  void guard() {
    _guarded = true;
  }

  /// The number of listeners subscribed to this beacon.
  int get listenersCount => _observers.length;

  bool get _isNullable => null is T;

  var _isEmpty = true;

  /// Returns true if the beacon has not been initialized.
  bool get isEmpty => _isEmpty;

  final String? _name;

  /// The name of the beacon. For debugging purposes.
  String get name => _name ?? runtimeType.toString();

  late final T _initialValue;

  /// The initial value of the beacon.
  T get initialValue => _initialValue;

  T? _previousValue;

  /// The previous value of the beacon.
  T? get previousValue => _previousValue;

  late T _value;
  final List<Consumer> _observers;

  final List<VoidCallback> _disposeCallbacks = [];
  var _isDisposed = false;

  /// Returns true if the beacon has been disposed.
  bool get isDisposed => _isDisposed;

  /// The hashcode of all widgets subscribed to this beacon.
  /// This should not be used directly.
  @Deprecated('This is an internal property. DO NOT USE IT DIRECTLY.')
  final $$widgetSubscribers$$ = <int>{};

  /// Return the current value of the beacon without subscribing to it.
  T peek() => _value;

  /// Equivalent to calling [value] getter.
  T call() => value;

  /// Returns the current value and subscribes to changes in the beacon
  /// when used within a `Beacon.effect` or `Beacon.derived`.
  T get value {
    if (_isEmpty) throw UninitializeLazyReadException(name);
    assert(() {
      if (isDisposed) {
        // coverage:ignore-start
        // ignore: avoid_print
        print(
          '[WARNING]: You read the value of a disposed beacon($name). '
          'This is not recommended and is probably a bug in your code. '
          'If you intend to reuse a beacon, try resetting instead of disposing it.',
        );
        // coverage:ignore-end
      }
      return true;
    }());
    currentConsumer?.startWatching(this);
    return _value;
  }

  void _setValue(T newValue, {bool force = false}) {
    assert(!_isDisposed, 'Cannot update the value of a disposed beacon.');
    if (_isEmpty) {
      _isEmpty = false;
      _initialValue = newValue;
      _value = newValue;
      _notifyListeners();
    } else if (_value != newValue || force) {
      _previousValue = _value;
      _value = newValue;

      _notifyListeners();
    }
  }

  void _notifyListeners() {
    final len = _observers.length;
    for (var i = 0; i < len; i++) {
      _observers[i].markDirty();
    }
  }

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  ///
  /// If [startNow] is true, the callback will be called immediately
  /// with the current value of the beacon.
  VoidCallback subscribe(
    void Function(T) callback, {
    bool startNow = true,
  }) {
    assert(!_isDisposed, 'Cannot subscribe to a disposed beacon.');
    final sub = Subscription(
      this,
      callback,
      startNow: startNow,
    );
    _observers.add(sub);
    return sub.dispose;
  }

  void _removeObserver(Consumer observer) {
    BeaconObserver.instance?.onStopWatch(observer.name, this);
    _observers.remove(observer);
  }

  /// Registers a callback to be called when the beacon is disposed.
  /// Returns a function that can be called to remove the callback.
  VoidCallback onDispose(VoidCallback callback) {
    assert(!_isDisposed, 'Cannot add a dispose callback to a disposed beacon.');

    _disposeCallbacks.add(callback);

    return () {
      _disposeCallbacks.remove(callback);
    };
  }

  /// Clears all registered listeners and
  /// resouces used by the beacon. You will
  /// not be able to update or subscribe to
  /// the beacon after it has been disposed.
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    for (final observer in _observers) {
      observer._sourceDisposed(this);
    }
    _observers.clear();
    // ignore: deprecated_member_use_from_same_package
    $$widgetSubscribers$$.clear();
    _previousValue = null;
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
  }

  @override
  String toString() => '$name(${_isEmpty ? 'uninitialized' : _value})';
}
