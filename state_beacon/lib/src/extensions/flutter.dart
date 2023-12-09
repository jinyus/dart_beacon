import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:state_beacon/src/base_beacon.dart';

class _BeaconListener {
  late VoidCallback unsub;
}

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
    final elementRef = WeakReference(context as Element);

    final listener = _BeaconListener();

    listener.unsub = subscribe((_) {
      assert(
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks,
          '$runtimeType mutated during a `build` method. Please use '
          '`SchedulerBinding.instance.scheduleTask(updateTask, Priority.idle)`, '
          '`SchedulerBinding.addPostFrameCallback(updateTask)`, '
          'or similar. to schedule an update after the current build completes.');

      if (elementRef.target?.mounted ?? false) {
        elementRef.target!.markNeedsBuild();
      }
      // only subscribe to one change per `build`
      listener.unsub();
    });

    return peek();
  }
}
