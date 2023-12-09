import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:state_beacon/src/base_beacon.dart';

// NB: The listener stays alive if the beacon is never modified.
//     This is rear and not a problem in practice, but it is something to be
//     aware of.

final Set<(int, int)> _subscribers = {};
final Set<(int, int)> _observers = {};

extension BeaconFlutterX<T> on BaseBeacon<T> {
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
    final key = (hashCode, context.hashCode);

    if (_subscribers.contains(key)) {
      // the widget has an active subscription to this beacon
      return peek();
    }

    _subscribers.add(key);

    final elementRef = WeakReference(context as Element);

    late VoidCallback unsub;

    unsub = subscribe((_) {
      assert(
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks,
          _buildMutationMsg);

      _subscribers.remove(key);
      // only subscribe to one change per `build`
      unsub();

      if (elementRef.target?.mounted ?? false) {
        elementRef.target!.markNeedsBuild();
      }
    });

    return peek();
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
  void observe(
    BuildContext context,
    void Function(T prev, T next) callback, {
    Duration delay = Duration.zero,
  }) {
    final key = (hashCode, context.hashCode);

    if (_observers.contains(key)) {
      // the widget has an active subscription to this beacon
      return;
    }

    _observers.add(key);

    final elementRef = WeakReference(context as Element);

    late VoidCallback unsub;

    unsub = subscribe((newValue) {
      Future.delayed(delay, () {
        if (elementRef.target?.mounted ?? false) {
          callback(previousValue as T, newValue);
        } else {
          _observers.remove(key);
          // keep subscription alive until widget is unmounted
          unsub();
        }
      });
    });
  }
}

const _buildMutationMsg =
    'A beacon was mutated during a `build` method. Please use '
    '`SchedulerBinding.instance.scheduleTask(updateTask, Priority.idle)`, '
    '`SchedulerBinding.addPostFrameCallback(updateTask)`, '
    'or similar. to schedule an update after the current build completes.';
