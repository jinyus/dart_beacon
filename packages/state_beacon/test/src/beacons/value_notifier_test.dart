import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should notify listener and call dispose callbacks', () {
    var beacon = ValueNotifierBeacon(0);
    var called = 0;

    void disposeTest() => called++;

    beacon.addListener(() => called++);

    expect(beacon.value, 0);

    beacon.set(1);

    expect(beacon.value, 1);
    expect(called, 1);

    beacon.addDisposeCallback(disposeTest);

    beacon.dispose();

    expect(called, 2);
  });

  test('should support Add/Remove Listerner', () {
    var beacon = Beacon.writable(0);
    var called = 0;
    void listener() => called++;

    beacon.addListener(listener);

    expect(beacon.value, 0);

    beacon.set(1);

    expect(beacon.value, 1);

    expect(called, 1);

    expect(beacon.listenersCount, 1);

    beacon.removeListener(listener);

    beacon.set(2);

    expect(beacon.value, 2);

    expect(called, 1);

    expect(beacon.listenersCount, 0);
  });
}
