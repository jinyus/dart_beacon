// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../common/async_value_test.dart';

void main() {
  test('should return immutable beacon', () {
    final beacon = Beacon.writable(10);
    final immutableBeacon = beacon.freeze();
    expect(immutableBeacon, isA<ReadableBeacon<int>>());
  });

  test('should toggle boolean beacon', () async {
    final beacon = Beacon.writable(true);

    beacon.toggle();

    BeaconScheduler.flush();

    expect(beacon.value, false);

    beacon.toggle();

    expect(beacon.value, true);
  });

  test('should increment/decrement num beacon', () async {
    final beacon = Beacon.writable(0);

    beacon.increment();

    BeaconScheduler.flush();

    expect(beacon.value, 1);

    beacon.increment();

    expect(beacon.value, 2);

    beacon.decrement();

    expect(beacon.value, 1);

    beacon.decrement();

    expect(beacon.value, 0);
  });

  test('should set correct async state', () async {
    final beacon = Beacon.writable<AsyncValue<int>>(AsyncData(0));

    expect(
      beacon.toStream(),
      emitsInOrder(
        [
          AsyncData(0),
          AsyncLoading<int>(),
          AsyncData(1),
          // start errorResult
          AsyncLoading<int>(),
          isA<AsyncError<int>>(),
        ],
      ),
    );

    BeaconScheduler.flush();

    await beacon.tryCatch(() => testFuture(false));

    BeaconScheduler.flush();

    expect(beacon.value, isA<AsyncData<int>>());

    await beacon.tryCatch(() => testFuture(true));

    BeaconScheduler.flush();

    expect(beacon.value, isA<AsyncError<int>>());
  });
}
