// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

// info: Don't want to use a mock library for this simple test
var _onCreateCalled = 0;
var _onUpdateCalled = 0;
var _onDisposeCalled = 0;
var _lazyOnCreate = false;
var _onWatchCalled = 0;
var _onStopWatchCalled = 0;

class MockLogginObserver extends LoggingObserver {
  MockLogginObserver({super.includeNames});

  @override
  void onCreate(BaseBeacon<dynamic> beacon, bool lazy) {
    if (!shouldContinue(beacon.name)) return;
    _lazyOnCreate = lazy;
    _onCreateCalled++;
  }

  @override
  void onDispose(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;
    _onDisposeCalled++;
  }

  @override
  void onUpdate(BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;
    _onUpdateCalled++;
  }

  @override
  void onWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;
    _onWatchCalled++;
  }

  @override
  void onStopWatch(String effectLabel, BaseBeacon<dynamic> beacon) {
    if (!shouldContinue(beacon.name)) return;
    _onStopWatchCalled++;
  }
}

void main() {
  BeaconObserver.instance = MockLogginObserver();

  setUp(() {
    _onCreateCalled = 0;
    _onUpdateCalled = 0;
    _onDisposeCalled = 0;
    _lazyOnCreate = false;
  });

  test('should call relevant methods of observer', () async {
    final a = Beacon.writable(10);
    final guard = Beacon.writable(true);
    a.value = 20;
    BeaconScheduler.flush();
    a.increment();
    BeaconScheduler.flush();
    a.dispose();
    BeaconScheduler.flush();

    final dispose = Beacon.effect(() {
      if (guard.value) {
        a.value;
      }
    });
    BeaconScheduler.flush();

    expect(_onCreateCalled, equals(2));
    expect(_onUpdateCalled, equals(2));
    expect(_onDisposeCalled, equals(1));
    expect(_onWatchCalled, equals(2));
    expect(_lazyOnCreate, isFalse);

    guard.value = false;

    BeaconScheduler.flush();

    expect(_onStopWatchCalled, equals(1));

    dispose();
    BeaconScheduler.flush();
    expect(_onStopWatchCalled, equals(2));
  });

  test('should call onCreate with lazy set as true', () {
    final _ = Beacon.lazyWritable<int>();
    expect(_onCreateCalled, equals(1));
    expect(_lazyOnCreate, isTrue);
  });

  test('should not call when label is not included', () {
    BeaconObserver.instance = MockLogginObserver(includeNames: ['foo']);

    final beacon = Beacon.lazyWritable<int>();

    beacon.value = 20;
    beacon.increment();
    beacon.dispose();

    expect(_onCreateCalled, equals(0));
    expect(_onUpdateCalled, equals(0));
    expect(_onDisposeCalled, equals(0));
    expect(_lazyOnCreate, isFalse);
  });
}
