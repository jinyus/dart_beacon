// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should update value only after specified duration', () async {
    final beacon = Beacon.debounced('', duration: k1ms);
    var called = 0;

    beacon
      ..subscribe((_) => called++)

      // simulate typing
      ..value = 'a'
      ..value = 'ap'
      ..value = 'app'
      ..value = 'appl'
      ..value = 'apple';

    // Value should still be 0 immediately after setting it
    expect(beacon.value, equals(''));

    // Value should be updated now
    await expectLater(beacon.next(), completion('apple'));

    expect(called, equals(2)); // Only one notification should be sent
  });

  test('should not debounce when duration is null', () async {
    final beacon = Beacon.debounced('');
    var called = 0;

    beacon
      ..subscribe((_) => called++)
      ..set('a');

    BeaconScheduler.flush();
    expect(called, 1);
    beacon.set('ap');
    BeaconScheduler.flush();
    expect(called, 2);
    beacon.set('app');
    BeaconScheduler.flush();
    expect(called, 3);
    beacon.set('appl');
    BeaconScheduler.flush();
    expect(called, 4);
    beacon.set('apple');

    BeaconScheduler.flush();
    expect(beacon.value, 'apple'); // should be updated immediately

    expect(called, 5); // 5 notifications should be sent
  });

  test('should debounce first value when lazy', () async {
    final b = Beacon.lazyDebounced<int>(duration: k10ms);
    final c = b.debounce(k10ms);

    b.set(5); // should be debounced

    expect(
      () => b.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );

    expect(
      () => c.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );

    await delay(k10ms * 1.5);

    expect(b.value, 5);

    // c is still debounced
    expect(
      () => c.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );

    await delay(k10ms * 1.5);

    expect(c.value, 5);
  });

  test('should not debounce first value when lazy', () async {
    final b = Beacon.lazyDebounced<int>(duration: k10ms, allowFirst: true);
    final c = b.debounce(k10ms, allowFirst: true);

    b.set(5); // should be debounced

    expect(b.value, 5);

    BeaconScheduler.flush(); // allow c to capture first value
    expect(c.value, 5);
  });
}
