import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should set throttle value updates', () async {
    var beacon = Beacon.throttled(10, duration: k10ms);

    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored
    expect(beacon.isBlocked, true);

    await Future.delayed(k10ms * 1.1);

    beacon.set(30);
    expect(beacon.value, equals(30)); // throttle time passed, update allowed
  });

  test('should respect newly set throttle duration', () async {
    var beacon = Beacon.throttled(10, duration: k10ms);

    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored

    beacon.setDuration(Duration.zero);

    beacon.set(30);
    expect(beacon.value, equals(30));
  });

  test('should not be blocked on reset and dispose', () async {
    var beacon = Beacon.throttled(10, duration: k10ms);

    beacon.set(20);
    expect(beacon.value, equals(20)); // first update allowed

    beacon.set(30);
    expect(beacon.value, equals(20)); // too fast, update ignored

    beacon.reset();

    beacon.set(30);
    expect(beacon.value, equals(30));

    beacon.set(40);
    expect(beacon.value, equals(30)); // too fast, update ignored

    beacon.dispose();

    beacon.set(40);
    expect(beacon.value, equals(40));
  });

  test('should update value at most once in specified duration', () async {
    final beacon = Beacon.throttled(0, duration: Duration(milliseconds: 100));
    var called = 0;

    beacon.subscribe((_) => called++);

    beacon.value = 10;
    expect(beacon.value, equals(10));

    beacon.value = 20;
    beacon.value = 30;
    beacon.value = 40;

    await Future.delayed(Duration(milliseconds: 50));

    expect(beacon.value, equals(10));

    await Future.delayed(Duration(milliseconds: 60));

    beacon.value = 30;

    expect(beacon.value, equals(30));

    // only ran twice even though value was updated 5 times
    expect(called, equals(2));
  });

  test('should buffer blocked updates', () async {
    final beacon = Beacon.lazyThrottled(
      duration: k10ms * 5,
      dropBlocked: false,
    );

    final values = <int>[];
    beacon.subscribe((value) {
      values.add(value);
    });

    beacon.set(1);
    expect(values, equals([1])); // first update is allowed

    beacon.set(2);
    await Future.delayed(Duration(milliseconds: 10));
    expect(values, equals([1])); // update blocked

    await Future.delayed(Duration(milliseconds: 55));

    expect(values, equals([1, 2])); // buffered update sent

    beacon.set(3);
    beacon.set(4);
    beacon.set(5);

    await Future.delayed(Duration(milliseconds: 10));

    expect(values, equals([1, 2])); // all blocked and buffered

    await Future.delayed(Duration(milliseconds: 100));

    expect(values, equals([1, 2, 3, 4]));

    await Future.delayed(Duration(milliseconds: 40));

    expect(values, equals([1, 2, 3, 4, 5]));
  });
}
