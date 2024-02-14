// ignore_for_file: strict_raw_type, inference_failure_on_instance_creation

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

Future<int> testFuture(bool crash) async {
  if (crash) {
    throw Exception('error');
  }
  return 1;
}

void main() {
  test('should return AsyncData when future is successful', () async {
    final result = await AsyncValue.tryCatch(() => testFuture(false));
    expect(result, isA<AsyncData>());
  });

  test('should return AsyncError when future throws', () async {
    final result = await AsyncValue.tryCatch(() => testFuture(true));
    expect(result, isA<AsyncError>());
  });

  test('should set the beacon supplied', () async {
    final beacon = Beacon.writable<AsyncValue<int>>(AsyncData(0));

    final beaconStream = beacon.stream;

    expect(
      beaconStream,
      emitsInOrder(
        [
          AsyncData(0),
          AsyncLoading<int>(),
          AsyncData(1),
          // start errorResult
          AsyncLoading<int>(),
          isA<AsyncError>(),
        ],
      ),
    );

    BeaconScheduler.flush();

    final successResult = await AsyncValue.tryCatch(
      () => testFuture(false),
      beacon: beacon,
    );

    BeaconScheduler.flush();

    expect(successResult, isA<AsyncData>());

    final errorResult = await AsyncValue.tryCatch(
      () => testFuture(true),
      beacon: beacon,
    );

    BeaconScheduler.flush();

    expect(errorResult, isA<AsyncError>());
  });

  test('should set optimistic result while loading', () async {
    final beacon = Beacon.writable<AsyncValue<int>>(AsyncData(0));

    final beaconStream = beacon.stream;

    expect(
      beaconStream,
      emitsInOrder(
        [
          AsyncData(0),
          AsyncData(1), // optimistic result

          // start errorResult
          AsyncData(2), // optimistic result
          isA<AsyncError>(),
        ],
      ),
    );

    BeaconScheduler.flush();

    final successResult = await AsyncValue.tryCatch(
      () => testFuture(false),
      beacon: beacon,
      optimisticResult: 1,
    );

    BeaconScheduler.flush();

    expect(successResult, isA<AsyncData>());

    final errorResult = await AsyncValue.tryCatch(
      () => testFuture(true),
      beacon: beacon,
      optimisticResult: 2,
    );

    BeaconScheduler.flush();

    expect(errorResult, isA<AsyncError>());
  });

  test('should share the same hashCode with sister instances', () {
    final data = AsyncData(1);
    final data2 = AsyncData(1);

    expect(data.hashCode, data2.hashCode);

    final load = AsyncLoading<int>();
    final load2 = AsyncLoading<int>();

    expect(load, load2);
    expect(load.hashCode, load2.hashCode);

    final stack = StackTrace.current;
    final error = AsyncError<int>('error', stack);
    final error2 = AsyncError<int>('error', stack);
    final error3 = AsyncError<int>('error');

    expect(error, error2);
    expect(error == error3, false);
    expect(error.hashCode, error2.hashCode);

    final idle = AsyncIdle<int>();
    final idle2 = AsyncIdle<int>();

    expect(idle, idle2);
    expect(idle.hashCode, idle2.hashCode);
  });

  test('should set lastData', () {
    final loading = AsyncLoading();

    expect(loading.lastData, null);
    expect(loading.valueOrNull, null);
    expect(loading.isIdleOrLoading, true);

    loading.setLastData(1);

    expect(loading.lastData, 1);
    expect(loading.valueOrNull, null);

    final idle = AsyncIdle();

    expect(idle.lastData, null);
    expect(idle.valueOrNull, null);
    expect(idle.isIdle, true);

    idle.setLastData(1);

    expect(idle.lastData, 1);
    expect(idle.valueOrNull, null);

    final error = AsyncError('error', StackTrace.current);

    expect(error.lastData, null);
    expect(error.valueOrNull, null);
    expect(error.isLoading, false);

    error.setLastData(1);

    expect(error.lastData, 1);
    expect(error.valueOrNull, null);

    final data = AsyncData(1);

    expect(data.lastData, 1);
    expect(data.valueOrNull, 1);
    expect(data.isLoading, false);

    // can't set lastData on AsyncData
    data.setLastData(2);

    expect(data.lastData, 1);
    expect(data.valueOrNull, 1);
  });
}
