import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

// info: Don't want to use a mock library for this simple test
var _onCreateCalled = 0;
var _onUpdateCalled = 0;
var _onDisposeCalled = 0;
var _lazyOnCreate = false;

class MockLogginObserver extends LoggingObserver {
  MockLogginObserver({super.includeLabels});

  @override
  void onCreate(BaseBeacon beacon, bool lazy) {
    if (!shouldContinue(beacon.debugLabel)) return;
    _lazyOnCreate = lazy;
    _onCreateCalled++;
  }

  @override
  void onDispose(BaseBeacon beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;
    _onDisposeCalled++;
  }

  @override
  void onUpdate(BaseBeacon beacon) {
    if (!shouldContinue(beacon.debugLabel)) return;
    _onUpdateCalled++;
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

    expect(_onCreateCalled, equals(1));
    expect(_onUpdateCalled, equals(2));
    expect(_onDisposeCalled, equals(1));
    expect(_lazyOnCreate, isFalse);
  });

  test('should call onCreate with lazy set as true', () {
    var _ = Beacon.lazyWritable<int>();
    expect(_onCreateCalled, equals(1));
    expect(_lazyOnCreate, isTrue);
  });

  test('should not call when label is not included', () {
    BeaconObserver.instance = MockLogginObserver(includeLabels: ['foo']);

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
