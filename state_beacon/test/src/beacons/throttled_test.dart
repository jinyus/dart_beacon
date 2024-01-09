import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should set throttle value updates', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored
    expect(beacon.isBlocked, true);

    await Future<void>.delayed(k10ms * 1.1);

    beacon.set(30);
    expect(beacon.value, equals(30)); // throttle time passed, update allowed
  });

  test('should respect newly set throttle duration', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored

    beacon
      ..setDuration(Duration.zero)
      ..set(30);

    expect(beacon.value, equals(30));
  });

  test('should not be blocked on reset and dispose', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored

    beacon
      ..reset()
      ..set(30);

    expect(beacon.value, equals(30));

    beacon.set(40);
    expect(beacon.value, equals(30)); // too fast, update ignored

    beacon
      ..dispose()
      ..set(40);
    expect(beacon.value, equals(40));
  });

  test('should update value at most once in specified duration', () async {
    final beacon = Beacon.throttled(0, duration: k10ms * 10);
    var called = 0;

    beacon
      ..subscribe((_) => called++)
      ..value = 10;

    expect(beacon.value, equals(10));

    beacon
      ..value = 20
      ..value = 30
      ..value = 40;

    await Future<void>.delayed(k10ms * 5);

    expect(beacon.value, equals(10));

    await Future<void>.delayed(k10ms * 6);

    beacon.value = 30;

    expect(beacon.value, equals(30));

    // only ran twice even though value was updated 5 times
    expect(called, equals(2));
  });

  test('should buffer blocked updates', () async {
    final beacon = Beacon.lazyThrottled<int>(
      duration: k10ms * 5,
      dropBlocked: false,
    );

    final values = <int>[];
    beacon
      ..subscribe(values.add)
      ..set(1);

    expect(values, equals([1])); // first update is allowed

    beacon.set(2);
    await Future<void>.delayed(k10ms);
    expect(values, equals([1])); // update blocked

    await Future<void>.delayed(k10ms * 5.5);

    expect(values, equals([1, 2])); // buffered update sent

    beacon
      ..set(3)
      ..set(4)
      ..set(5);

    await Future<void>.delayed(k10ms);

    expect(values, equals([1, 2])); // all blocked and buffered

    await Future<void>.delayed(k10ms * 10);

    expect(values, equals([1, 2, 3, 4]));

    await Future<void>.delayed(k10ms * 4);

    expect(values, equals([1, 2, 3, 4, 5]));
  });
}
