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

    await BeaconScheduler.settle();
    expect(called, 1);
    beacon.set('ap');
    await BeaconScheduler.settle();
    expect(called, 2);
    beacon.set('app');
    await BeaconScheduler.settle();
    expect(called, 3);
    beacon.set('appl');
    await BeaconScheduler.settle();
    expect(called, 4);
    beacon.set('apple');

    await BeaconScheduler.settle();
    expect(beacon.value, 'apple'); // should be updated immediately

    expect(called, 5); // 5 notifications should be sent
  });
}
