import 'package:flutter/scheduler.dart';
import 'package:state_beacon_core/state_beacon_core.dart' as core;

/// `Effects` are not synchronous, their execution is controlled by a scheduler.
/// When a dependency of an `effect` changes, it is added to a queue and
/// the scheduler decides when is the best time to flush the queue.
/// By default, the queue is flushed with a DARTVM microtask which runs
/// on the next loop; this can be changed by setting a custom scheduler.
/// Flutter comes with its own scheduler, so it is recommended to use
/// flutter's scheduler when using beacons in a flutter app.
/// This can be done by calling `BeaconScheduler.useFlutterScheduler();`
/// in the `main` function.
///
/// ```dart
/// void main() {
///  BeaconScheduler.useFlutterScheduler();
///
///  runApp(const MyApp());
/// }
/// ```
abstract class BeaconScheduler {
  /// Runs all queued effects/subscriptions
  /// This is made available for testing and should not be used in production
  static void flush() => core.BeaconScheduler.flush();

  /// This scheduler uses the Flutter SchedulerBinding to
  /// schedule updates to be processed after the current frame.
  static void useFlutterScheduler() {
    _flushing = false;
    core.BeaconScheduler.setScheduler(_flutterScheduler);
  }

  /// This scheduler limits the frequency that updates
  /// are processed to 60 times per second.
  static void use60fpsScheduler() {
    core.BeaconScheduler.use60fpsScheduler();
  }

  /// This scheduler limits the frequency that updates
  /// are processed to a custom fps.
  static void useCustomFpsScheduler(int updatesPerSecond) {
    core.BeaconScheduler.useCustomFpsScheduler(updatesPerSecond);
  }

  /// Sets the scheduler to the provided function
  // coverage:ignore-start
  static void setCustomScheduler(void Function() scheduler) {
    core.BeaconScheduler.setScheduler(scheduler);
  }
  // coverage:ignore-end

  /// This scheduler processes updates synchronously. This is not recommended
  /// for production apps and only provided to make testing easier.
  ///
  /// With this scheduler, you aren't protected from stackoverflows when
  /// an effect mutates a beacon that it depends on. This is a infinite loop
  /// with the sync scheduler.
  // static void useSyncScheduler() {
  //   core.BeaconScheduler.useSyncScheduler();
  // }
}

var _flushing = false;

void _flutterScheduler() {
  if (_flushing) return;
  _flushing = true;
  if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
    Future.microtask(() {
      core.BeaconScheduler.flush();
      _flushing = false;
    });
  } else {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      core.BeaconScheduler.flush();
      _flushing = false;
    });
  }
}
