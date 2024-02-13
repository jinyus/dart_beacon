import 'package:flutter/scheduler.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

/// Class used to switch between different schedulers.
abstract class FlutterBeacon {
  /// This scheduler uses the Flutter SchedulerBinding to
  /// schedule updates to be processed after the current frame.
  static void useFlutterScheduler() {
    _flushing = false;
    BeaconScheduler.setScheduler(_flutterScheduler);
  }

  /// This scheduler limits the frequency that updates
  /// are processed to 60 times per second.
  static void use60fpsScheduler() {
    _flushing = false;
    BeaconScheduler.setScheduler(_sixtyfpsScheduler);
  }

  /// This scheduler processes updates synchronously. This is not recommended
  /// for production apps and only provided to make testing easier.
  ///
  /// With this scheduler, you aren't protected from stackoverflows when
  /// an effect mutates a beacon that it depends on. This is a infinite loop
  /// with the sync scheduler.
  // static void useSyncScheduler() {
  //   BeaconScheduler.useSyncScheduler();
  // }
}

var _flushing = false;
const _k16ms = Duration(milliseconds: 500);

void _sixtyfpsScheduler() {
  if (_flushing) return;
  _flushing = true;
  Future.delayed(_k16ms, () {
    BeaconScheduler.flush();
    _flushing = false;
  });
}

void _flutterScheduler() {
  if (_flushing) return;
  _flushing = true;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    BeaconScheduler.flush();
    _flushing = false;
  });
}
