// ignore_for_file: avoid_print

import 'package:state_beacon_core/src/base_beacon.dart';

/// A class that observes beacons.
abstract class BeaconObserver {
  /// Called when a beacon is created
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy);

  /// Called when a beacon is updated
  void onUpdate(BaseBeacon<dynamic> beacon);

  /// Called when a beacon is watched by an effect or derived beacon
  void onWatch(String effectName, BaseBeacon<dynamic> beacon);

  /// Called when a beacon is no longer watched by an effect or derived beacon
  void onStopWatch(String effectName, BaseBeacon<dynamic> beacon);

  /// Called when a beacon is disposed
  void onDispose(BaseBeacon<dynamic> beacon);

  /// The current instance of the observer
  static BeaconObserver? instance;
}

/// A beacon observer that logs to the console.
class LoggingObserver implements BeaconObserver {
  /// @macro [LoggingObserver]
  LoggingObserver({this.includeNames});

  /// The names of beacons to include in the logs.
  final List<String>? includeNames;

  // this is tested with mocks
  // don't want to print to console in tests
  // coverage:ignore-start

  @override
  void onUpdate(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
"${beacon.name}" was updated:
  old: ${beacon.previousValue}
  new: ${beacon.peek()}\n\n''',
    );
  }

  @override
  void onDispose(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print('\n"${beacon.name}" was disposed\n\n');
  }

  @override
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy) {
    if (!shouldContinue(beacon.name)) return;

    final lazyLabel = lazy ? 'Lazy' : '';
    print('\n${lazyLabel}Beacon created: ${beacon.name}\n\n');
  }

  /// Returns whether the beacon with the given [name] should be logged.
  bool shouldContinue(String name) {
    if (includeNames == null) return true;
    return includeNames?.contains(name) ?? false;
  }

  @override
  void onWatch(String effectName, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
$effectName is watching ${beacon.name}\n\n''',
    );
  }

  @override
  void onStopWatch(String effectName, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
$effectName stopped watching ${beacon.name}\n\n''',
    );
  }
  // coverage:ignore-end
}
