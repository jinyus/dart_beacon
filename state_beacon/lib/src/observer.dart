import 'package:flutter/foundation.dart';
import 'package:state_beacon/src/base_beacon.dart';

abstract class BeaconObserver {
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy);

  void onUpdate(BaseBeacon<dynamic> beacon);

  void onWatch(String effectLabel, BaseBeacon<dynamic> beacon);

  void onStopWatch(String effectLabel, BaseBeacon<dynamic> beacon);

  void onDispose(BaseBeacon<dynamic> beacon);

  static BeaconObserver? instance;
}

class LoggingObserver implements BeaconObserver {
  final List<String>? includeLabels;

  LoggingObserver({this.includeLabels});

  // this is tested with mocks
  // don't want to print to console in tests
  // coverage:ignore-start

  @override
  void onUpdate(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    debugPrint(
      '''
Beacon updated:
  label: ${beacon.debugLabel}
  old: ${beacon.previousValue}
  new: ${beacon.peek()}\n''',
    );
  }

  @override
  void onDispose(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    debugPrint('Beacon disposed: ${beacon.debugLabel}\n');
  }

  @override
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy) {
    if (!shouldContinue(beacon.debugLabel)) return;

    final lazyLabel = lazy ? 'Lazy' : '';
    debugPrint('${lazyLabel}Beacon created: ${beacon.debugLabel}\n');
  }

  bool shouldContinue(String label) {
    if (includeLabels == null) return true;
    return includeLabels?.contains(label) ?? false;
  }

  @override
  void onWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    debugPrint(
      '''
Effect watching beacon:
  effect: $effectLabel
  beacon: ${beacon.debugLabel}\n''',
    );
  }

  @override
  void onStopWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    debugPrint(
      '''
Effect stopped watching beacon:
  effect: $effectLabel
  beacon: ${beacon.debugLabel}\n''',
    );
  }
  // coverage:ignore-end
}
