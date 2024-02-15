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

import 'package:state_beacon_core/src/common/exceptions.dart';
import 'package:state_beacon_core/src/creator/creator.dart';

import 'common/async_value.dart';
import 'common/types.dart';
import 'observer.dart';

part 'beacons/async.dart';
part 'beacons/awaited.dart';
part 'beacons/buffered.dart';
part 'beacons/debounced.dart';
part 'beacons/derived.dart';
part 'beacons/family.dart';
part 'beacons/filtered.dart';
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
part 'consumer.dart';
part 'consumers/effect.dart';
part 'consumers/subscription.dart';
part 'extensions/chain.dart';
part 'extensions/wrap.dart';
part 'mixins/beacon_wrapper.dart';
part 'scheduler.dart';
part 'untracked.dart';

/// The current consumer.
Consumer? currentConsumer;

/// The current list of producers accessed when evaluating a reactive function.
List<Producer<dynamic>?> currentGets = [];

/// The current index of this producer in the consumer's list of producers.
int currentGetsIndex = 0;

/// The status of a consumer.
enum Status {
  /// The consumer is clean.
  clean,

  /// The consumer is maybe dirty. Check its sources.
  check,

  /// The consumer is dirty.
  dirty;
}

/// The base class for all beacons.
abstract class Producer<T> {
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
  final widgetSubscribers = <int>{};

  /// Return the current value of the beacon without subscribing to it.
  T peek() => _value;

  /// Equivalent to calling [value] getter.
  T call() => value;

  /// Returns the current value and subscribes to changes in the beacon
  /// when used within a `Beacon.effect` or `Beacon.derived`.
  T get value {
    if (_isEmpty) throw UninitializeLazyReadException(name);
    currentConsumer?.startWatching(this);
    return _value;
  }

  void _setValue(T newValue, {bool force = false}) {
    if (_isEmpty) {
      _isEmpty = false;
      _initialValue = newValue;
      _previousValue = newValue;
      _value = newValue;
      _notifyListeners();
    } else if (_value != newValue || force) {
      _previousValue = _value;
      _value = newValue;

      _notifyListeners();
    }
  }

  void _notifyListeners() {
    for (var i = 0; i < _observers.length; i++) {
      _observers[i].markDirty();
    }
  }

  /// Subscribes to changes in the beacon
  /// returns a function that can be called to unsubscribe
  ///
  /// If [startNow] is true, the callback will be called immediately
  /// with the current value of the beacon.
  ///
  /// If [synchronous] is true, the callback will be ran synchronously.
  /// This also means automatic batching of updates will be disabled.
  VoidCallback subscribe(
    void Function(T) callback, {
    bool startNow = true,
    bool synchronous = false,
  }) {
    final sub = Subscription(
      this,
      callback,
      startNow: startNow,
      synchronous: synchronous,
    );
    _observers.add(sub);
    return sub.dispose;
  }

  void _removeObserver(Consumer observer) {
    BeaconObserver.instance?.onStopWatch(observer.name, this);
    _observers.remove(observer);
  }

  /// Registers a callback to be called when the beacon is disposed.
  void onDispose(VoidCallback callback) {
    if (isDisposed) return;

    _disposeCallbacks.add(callback);
  }

  /// Clears all registered listeners and
  /// reset the beacon to its initial state.
  void dispose() {
    _observers.clear();
    // ignore: deprecated_member_use_from_same_package
    widgetSubscribers.clear();
    if (!_isEmpty) _value = _initialValue;
    _previousValue = null;
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    _isDisposed = true;
    // BeaconObserver.instance?.onDispose(this);
  }

  @override
  String toString() => '$name(${_isEmpty ? 'uninitialized' : _value})';
}
