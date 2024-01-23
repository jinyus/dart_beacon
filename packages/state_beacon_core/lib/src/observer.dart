import 'package:state_beacon_core/src/base_beacon.dart';

abstract class BeaconObserver {
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy);

  void onUpdate(BaseBeacon<dynamic> beacon);

  void onWatch(String effectName, BaseBeacon<dynamic> beacon);

  void onStopWatch(String effectName, BaseBeacon<dynamic> beacon);

  void onDispose(BaseBeacon<dynamic> beacon);

  static BeaconObserver? instance;
}

class LoggingObserver implements BeaconObserver {
  final List<String>? includeNames;

  LoggingObserver({this.includeNames});

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
