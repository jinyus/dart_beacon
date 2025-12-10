import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should throttle value updates', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, 20); // first update allowed

    beacon.set(30);
    expect(beacon.value, 20); // too fast, update ignored
    expect(beacon.isBlocked, true);

    await delay(k10ms * 1.1);

    beacon.set(30);

    // throttle time passed, update allowed
    expect(beacon.value, 30);
  });

  test('should not send notifications when blocked', () async {
    final beacon = Beacon.throttled(0, duration: k1ms, name: 'a');
    var ran = 0;

    beacon.subscribe((_) => ran++);

    BeaconScheduler.flush();

    expect(ran, 1);

    beacon
      ..set(1)
      ..set(2)
      ..set(3)
      ..set(4)
      ..set(5);

    expect(beacon.value, 1); // should be updated immediately
    expect(beacon.isBlocked, true);

    BeaconScheduler.flush();
    expect(ran, 2); // 5 notifications should be sent
  });

  test('should respect newly set throttle duration', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, 20); // first update allowed

    beacon.set(30);
    expect(beacon.value, 20); // too fast, update ignored

    beacon
      ..setDuration(Duration.zero)
      ..set(30);

    expect(beacon.value, 30);
  });

  test('should not be blocked on reset', () async {
    final beacon = Beacon.throttled(10, duration: k10ms);

    // ignore: cascade_invocations
    beacon.set(20);
    expect(beacon.value, 20); // first update allowed

    beacon.set(30);
    expect(beacon.value, 20); // too fast, update ignored

    beacon
      ..reset()
      ..set(30);

    expect(beacon.value, 30);

    beacon.set(40);
    expect(beacon.value, 30); // too fast, update ignored
  });

  test('should update value at most once in specified duration', () async {
    final beacon = Beacon.throttled(0, duration: k10ms);
    var called = 0;

    beacon
      ..subscribe((_) => called++)
      ..value = 10
      ..value = 20
      ..value = 30
      ..value = 40;

    expect(beacon.value, 10);

    await delay(k1ms * 3);

    beacon.increment();

    expect(beacon.value, 10); // still blocked

    await delay(k10ms);

    // 13ms passed, update allowed
    beacon.value = 50;

    expect(beacon.value, 50);

    BeaconScheduler.flush();

    // only ran twice even though value was updated 5 times
    expect(called, 2);
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

    BeaconScheduler.flush();

    expect(values, [1]); // first update is allowed

    beacon.set(2);
    await delay(k10ms);
    expect(values, [1]); // update blocked

    await delay(k10ms * 5.5);

    expect(values, [1, 2]); // buffered update sent

    beacon
      ..set(3)
      ..set(4)
      ..set(5);

    await delay(k10ms);

    expect(values, [1, 2]); // all blocked and buffered

    await delay(k10ms * 10);

    expect(values, [1, 2, 3, 4]);

    await delay(k10ms * 4);

    expect(values, [1, 2, 3, 4, 5]);
  });

  test('should not send notifications when blocked', () async {
    final beacon = Beacon.throttled(0, duration: k1ms);
    var called = 0;

    beacon
      ..subscribe((_) => called++)
      ..set(1)
      ..set(2)
      ..set(3)
      ..set(4)
      ..set(5);

    BeaconScheduler.flush();
    expect(called, 1); // 5 notifications should be sent

    expect(beacon.value, 1); // should be updated immediately
    expect(beacon.isBlocked, true);

    BeaconScheduler.flush();
    expect(called, 1); // 5 notifications should be sent
  });

  test('should not throttle when duration is null', () async {
    final beacon = Beacon.throttled(0);
    var called = 0;

    beacon
      ..subscribe((_) => called++)
      ..set(1);
    BeaconScheduler.flush();
    expect(called, 1);
    beacon.set(2);
    BeaconScheduler.flush();
    expect(called, 2);
    beacon.set(3);
    BeaconScheduler.flush();
    expect(called, 3);
    beacon.set(4);
    BeaconScheduler.flush();
    expect(called, 4);
    beacon.set(5);

    BeaconScheduler.flush();
    expect(beacon.value, 5); // should be updated immediately

    expect(called, 5); // 5 notifications should be sent
  });

  test('should handle force parameter correctly in buffered updates', () async {
    final beacon = Beacon.throttled(
      0,
      duration: k10ms * 5,
      dropBlocked: false,
    );

    final values = <int>[];
    var notifyCount = 0;

    beacon.subscribe((val) {
      values.add(val);
      notifyCount++;
    });

    beacon.set(1);
    BeaconScheduler.flush();
    expect(values, [1]);
    expect(notifyCount, 1);

    beacon.set(1, force: false);
    await delay(k10ms);
    expect(values, [1]);
    expect(notifyCount, 1);

    await delay(k10ms * 5);
    expect(values, [1]);
    expect(notifyCount, 1);

    beacon.set(1, force: true);
    await delay(k10ms);

    await delay(k10ms * 5);
    expect(values, [1, 1]);
    expect(notifyCount, 2);
  });
}