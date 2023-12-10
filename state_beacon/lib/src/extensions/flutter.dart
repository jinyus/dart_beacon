import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:state_beacon/src/base_beacon.dart';

typedef _ElementUnsub = ({
  WeakReference<Element> elementRef,
  void Function() unsub
});

typedef ObserverCallback<T> = void Function(T prev, T next);

final Map<int, _ElementUnsub> _subscribers = {};

const _k10seconds = Duration(seconds: 10);

var _lastPurge = DateTime.now().subtract(_k10seconds);

extension BeaconUtils<T> on BaseBeacon<T> {
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

  ///  @override
  ///  Widget build(BuildContext context) {
  ///    final count = counter.watch(context);
  ///    return Text(count.toString());
  ///  }
  ///}
  /// ```
  T watch(BuildContext context) {
    return _watch(this, context);
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
    _watch(
      this,
      context,
      callback: callback,
    );
  }
}

T _watch<T>(
  BaseBeacon<T> beacon,
  BuildContext context, {
  ObserverCallback<T>? callback,
}) {
  final isObserving = callback != null;

  final key = Object.hashAll([
    beacon.hashCode,
    context.hashCode,
    if (isObserving) 'isObserving', // 1 widget should only observe once
  ]);

  void rebuildWidget(T value) {
    _assertNotBuildMutation();

    final record = _subscribers[key]!;

    final target = record.elementRef.target;
    final isMounted = target?.mounted ?? false;

    if (isMounted) {
      if (isObserving) {
        callback(beacon.previousValue as T, value);
      } else {
        target!.markNeedsBuild();
      }
    } else {
      final removedRecord = _subscribers.remove(key);
      removedRecord?.unsub();
    }
  }

  if (!_subscribers.containsKey(key)) {
    final unsub = beacon.subscribe(rebuildWidget);

    _subscribers[key] = (
      elementRef: WeakReference(context as Element),
      unsub: unsub,
    );
  }

  _cleanUp();

  return beacon.peek();
}

_assertNotBuildMutation() {
  assert(
      SchedulerBinding.instance.schedulerPhase !=
          SchedulerPhase.persistentCallbacks,
      _buildMutationMsg);
}

void _cleanUp() {
  final now = DateTime.now();

  // only clean up if last clean was more  than 10 seconds ago
  if (now.difference(_lastPurge) < _k10seconds) {
    return;
  }

  _lastPurge = now;

  _subscribers.removeWhere((key, value) {
    final shouldRemove = value.elementRef.target == null;
    if (shouldRemove) {
      value.unsub();
    }
    return shouldRemove;
  });
}

const _buildMutationMsg =
    'A beacon was mutated during a `build` method. Please use '
    '`SchedulerBinding.instance.scheduleTask(updateTask, Priority.idle)`, '
    '`SchedulerBinding.addPostFrameCallback(updateTask)`, '
    'or similar. to schedule an update after the current build completes.';
