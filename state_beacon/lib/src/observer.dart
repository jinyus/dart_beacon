import 'package:flutter/foundation.dart';
import 'package:state_beacon/src/base_beacon.dart';

abstract class BeaconObserver {
  void onCreate(BaseBeacon beacon, bool lazy);

  void onUpdate(BaseBeacon beacon);

  void onDispose(BaseBeacon beacon);

  static BeaconObserver? instance;
}

class LoggingObserver implements BeaconObserver {
  final List<String>? includeLabels;

  LoggingObserver({this.includeLabels});

  // this is tested with mocks
  // dont want to print to console in tests
  // coverage:ignore-start

  @override
  void onUpdate(BaseBeacon beacon) {
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
  void onDispose(BaseBeacon beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    debugPrint('Beacon disposed: ${beacon.debugLabel}\n');
  }

  @override
  void onCreate(BaseBeacon beacon, bool lazy) {
    if (!shouldContinue(beacon.debugLabel)) return;

    final lazyLabel = lazy ? 'Lazy' : '';
    debugPrint('${lazyLabel}Beacon created: ${beacon.debugLabel}\n');
  }
  // coverage:ignore-end

  bool shouldContinue(String label) {
    if (includeLabels == null) return true;
    return includeLabels?.contains(label) ?? false;
  }
}
