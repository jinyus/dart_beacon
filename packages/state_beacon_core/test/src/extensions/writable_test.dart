// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../async_value_test.dart';

void main() {
  test('should return immutable beacon', () {
    final beacon = Beacon.writable(10);
    final immutableBeacon = beacon.freeze();
    expect(immutableBeacon, isA<ReadableBeacon<int>>());
  });
  test('should toggle boolean beacon', () {
    final beacon = Beacon.writable(true);

    beacon.toggle();

    expect(beacon.value, false);

    beacon.toggle();

    expect(beacon.value, true);
  });

  test('should increment/decrement num beacon', () {
    final beacon = Beacon.writable(0);

    beacon.increment();

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
      beacon.stream,
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

    await beacon.tryCatch(() => testFuture(false));

    expect(beacon.value, isA<AsyncData<int>>());

    await beacon.tryCatch(() => testFuture(true));

    expect(beacon.value, isA<AsyncError<int>>());
  });
}
