import 'package:state_beacon_core/src/base_beacon.dart';

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

    print(
      '''

"${beacon.debugLabel}" was updated:
  old: ${beacon.previousValue}
  new: ${beacon.peek()}\n\n\n''',
    );
  }

  @override
  void onDispose(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    print('\n"${beacon.debugLabel}" was disposed\n\n');
  }

  @override
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy) {
    if (!shouldContinue(beacon.debugLabel)) return;

    final lazyLabel = lazy ? 'Lazy' : '';
    print('\n${lazyLabel}Beacon created: ${beacon.debugLabel}\n\n');
  }

  bool shouldContinue(String label) {
    if (includeLabels == null) return true;
    return includeLabels?.contains(label) ?? false;
  }

  @override
  void onWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    print(
      '''

$effectLabel is watching ${beacon.debugLabel}\n\n''',
    );
  }

  @override
  void onStopWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;

    print(
      '''

$effectLabel stopped watching ${beacon.debugLabel}\n\n''',
    );
  }
  // coverage:ignore-end
}
