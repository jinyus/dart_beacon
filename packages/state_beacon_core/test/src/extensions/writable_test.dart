import 'package:test/test.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

import '../async_value_test.dart';

void main() {
  test('should return immutable beacon', () {
    var beacon = Beacon.writable(10);
    var immutableBeacon = beacon.freeze();
    expect(immutableBeacon, isA<ReadableBeacon<int>>());
  });
  test('should toggle boolean beacon', () {
    var beacon = Beacon.writable(true);

    beacon.toggle();

    expect(beacon.value, false);

    beacon.toggle();

    expect(beacon.value, true);
  });

  test('should increment/decrement num beacon', () {
    var beacon = Beacon.writable(0);

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

    final beaconStream = beacon.toStream();

    expect(
      beaconStream,
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
