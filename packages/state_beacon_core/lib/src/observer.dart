// ignore_for_file: avoid_print

import 'package:state_beacon_core/state_beacon_core.dart';

/// The BaseBeacon type. Alias for Producer.
typedef BaseBeacon<T> = Producer<T>;

/// A class that observes beacons.
abstract class BeaconObserver {
  /// Called when a beacon is created
  void onCreate(ReadableBeacon<dynamic> beacon, bool lazy);

  /// Called when a beacon is updated
  void onUpdate(ReadableBeacon<dynamic> beacon);

  /// Called when a beacon is watched by an effect or derived beacon
  void onWatch(String consumerName, BaseBeacon<dynamic> beacon);

  /// Called when a beacon is no longer watched by an effect or derived beacon
  void onStopWatch(String consumerName, BaseBeacon<dynamic> beacon);

  /// Called when a beacon is disposed
  void onDispose(ReadableBeacon<dynamic> beacon);

  /// The current instance of the observer
  static BeaconObserver? instance;

  /// Sets the current instance of the observer to the [LoggingObserver].
  /// Alias to BeaconObserver.instance = LoggingObserver();
  // coverage:ignore-start
  static void useLoggingObserver({
    List<String>? includeNames,
    List<String>? excludeNames,
  }) {
    instance = LoggingObserver(
      includeNames: includeNames,
      excludeNames: excludeNames,
    );
  }
  // coverage:ignore-end
}

/// A beacon observer that logs to the console.
class LoggingObserver implements BeaconObserver {
  /// @macro [LoggingObserver]
  LoggingObserver({this.includeNames, this.excludeNames});

  /// The names of beacons to include in the logs.
  final List<String>? includeNames;

  /// The names of beacons to exclude from the logs.
  final List<String>? excludeNames;

  // this is tested with mocks
  // don't want to print to console in tests
  // coverage:ignore-start

  @override
  void onUpdate(ReadableBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
"${beacon.name}" was updated:
  old: ${beacon.previousValue}
  new: ${beacon.peek()}\n''',
    );
  }

  @override
  void onDispose(ReadableBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print('\n"${beacon.name}" was disposed\n');
  }

  @override
  void onCreate(ReadableBeacon<dynamic> beacon, bool lazy) {
    if (!shouldContinue(beacon.name)) return;

    final lazyLabel = lazy ? 'Lazy' : '';
    print('\n${lazyLabel}Beacon created: ${beacon.name}\n');
  }

  /// Returns whether the beacon with the given [name] should be logged.
  bool shouldContinue(String name) {
    if (includeNames != null && !includeNames!.contains(name)) return false;
    if (excludeNames != null && excludeNames!.contains(name)) return false;
    return true;
  }

  @override
  void onWatch(String effectName, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
$effectName is watching ${beacon.name}\n''',
    );
  }

  @override
  void onStopWatch(String effectName, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;

    print(
      '''
$effectName stopped watching ${beacon.name}\n''',
    );
  }
  // coverage:ignore-end
}
