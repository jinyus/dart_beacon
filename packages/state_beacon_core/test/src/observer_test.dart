import 'package:test/test.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

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

  test('should call relevant methods of observer', () {
    var beacon = Beacon.writable(10);
    beacon.value = 20;
    beacon.increment();
    beacon.dispose();

    var dispose = Beacon.effect(() {
      beacon.value;
    });

    expect(_onCreateCalled, equals(1));
    expect(_onUpdateCalled, equals(2));
    expect(_onDisposeCalled, equals(1));
    expect(_onWatchCalled, equals(1));
    expect(_lazyOnCreate, isFalse);

    dispose();
    expect(_onStopWatchCalled, equals(1));
  });

  test('should call onCreate with lazy set as true', () {
    var _ = Beacon.lazyWritable<int>();
    expect(_onCreateCalled, equals(1));
    expect(_lazyOnCreate, isTrue);
  });

  test('should not call when label is not included', () {
    BeaconObserver.instance = MockLogginObserver(includeNames: ['foo']);

    var beacon = Beacon.lazyWritable<int>();

    beacon.value = 20;
    beacon.increment();
    beacon.dispose();

    expect(_onCreateCalled, equals(0));
    expect(_onUpdateCalled, equals(0));
    expect(_onDisposeCalled, equals(0));
    expect(_lazyOnCreate, isFalse);
  });
}
