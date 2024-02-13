import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should convert a beacon to a stream', () async {
    final beacon = Beacon.writable(0);
    final stream = beacon.stream;

    expect(stream, isA<Stream<int>>());

    expect(
      stream,
      emitsInOrder([
        0,
        1,
        2,
        emitsDone,
      ]),
    );

    await BeaconScheduler.settle();
    beacon.value = 1;
    await BeaconScheduler.settle();
    beacon.value = 2;
    await BeaconScheduler.settle();
    beacon.dispose();
    await BeaconScheduler.settle();
  });

  test('should cache stream', () {
    final beacon = Beacon.writable(0);

    final stream1 = beacon.stream;
    final stream2 = beacon.stream;

    expect(stream1.hashCode, stream2.hashCode);
  });

  test('next method completes with the setted value', () async {
    final beacon = Beacon.writable(0);

    Timer(k10ms, () => beacon.set(42));

    final result = await beacon.next();

    expect(result, 42);
  });

  test('next method with filter only completes with matching values', () async {
    final beacon = Beacon.writable(0);

    final futureValue = beacon.next(filter: (value) => value.isEven);

    Timer(
      k10ms,
      () async {
        beacon.set(3); // Not even, should be ignored
        await BeaconScheduler.settle();
        beacon.set(42);
      }, // Even, should be completed with this value
    );

    final result = await futureValue;

    expect(result, 42);
  });

  test('next method with timeout completes with peek value on timeout',
      () async {
    final beacon = Beacon.writable(0);

    final futureValue = beacon.next(timeout: k10ms);

    // Delay beyond timeout
    await delay(k10ms * 2);

    final result = await futureValue;

    expect(result, beacon.peek());
  });

  test('next method unsubscribes after value is setted', () async {
    final beacon = Beacon.writable(0);

    final futureValue = beacon.next();

    expect(beacon.listenersCount, 1);

    beacon.set(42);

    await BeaconScheduler.settle();

    await futureValue; // Ensure the future is completed

    expect(beacon.listenersCount, 0);

    // set more values, and the future should not complete again
    beacon.set(99);

    await BeaconScheduler.settle();

    // Assert that the future didn't complete again
    expect(futureValue, completes);

    // should be the same value as before
    await expectLater(await futureValue, 42);
  });

  test('should return a BufferedCountBeacon', () async {
    final beacon = Beacon.writable(0);

    final buffered = beacon.buffer(3);

    expect(buffered, isA<BufferedCountBeacon<int>>());

    beacon.set(1);
    await BeaconScheduler.settle();
    beacon.set(2);
    await BeaconScheduler.settle();
    beacon.set(3);
    await BeaconScheduler.settle();

    expect(buffered.value, [0, 1, 2]);
  });

  test('should work properly when wrapping a lazy beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final beacon = Beacon.lazyWritable<int>();

    final buffered = beacon.buffer(3);
    final bufferedTime = beacon.bufferTime(duration: k10ms);
    final debounced = beacon.debounce(duration: k10ms);
    final throttled = beacon.throttle(duration: k10ms);
    final filtered = beacon.filter(
      filter: (p0, p1) => p1.isEven,
    );

    beacon.set(1);
    await BeaconScheduler.settle();
    beacon.set(2);
    await BeaconScheduler.settle();
    beacon.set(3);
    await BeaconScheduler.settle();
    beacon.set(4);
    await BeaconScheduler.settle();
    beacon.set(5);
    await BeaconScheduler.settle();

    expect(buffered.value, [1, 2, 3]);

    expect(debounced.value, 1);

    expect(throttled.value, 1);

    expect(filtered.value, 4);

    expect(bufferedTime.value, <int>[]);

    await delay(k10ms * 2);

    expect(debounced.value, 5);

    expect(throttled.value, 1);

    expect(bufferedTime.value, <int>[1, 2, 3, 4, 5]);
  });

  test('should return a BufferedTimeBeacon', () async {
    final beacon = Beacon.writable(0);

    final buffered = beacon.bufferTime(duration: k10ms);

    expect(buffered, isA<BufferedTimeBeacon<int>>());

    buffered.add(1);
    await BeaconScheduler.settle();
    buffered.add(2);
    await BeaconScheduler.settle();
    buffered.add(3);
    await BeaconScheduler.settle();

    expect(buffered.currentBuffer.value, [0, 1, 2, 3]);
    expect(buffered.value, isEmpty);

    await delay(k10ms * 2);
    expect(buffered.value, [0, 1, 2, 3]);
    expect(buffered.currentBuffer.value, isEmpty);
  });

  test('should return a DebouncedBeacon', () async {
    final beacon = Beacon.writable(0);

    final debounced = beacon.debounce(duration: k10ms);

    expect(debounced, isA<DebouncedBeacon<int>>());

    beacon.set(1);
    await BeaconScheduler.settle();
    beacon.set(2);
    await BeaconScheduler.settle();
    beacon.set(3);
    await BeaconScheduler.settle();

    expect(debounced.value, 0);

    await delay(k10ms * 2);

    expect(debounced.value, 3);
  });

  test('should return a ThrottledBeacon', () async {
    final beacon = Beacon.writable(0);

    final throttled = beacon.throttle(duration: k10ms);

    expect(throttled, isA<ThrottledBeacon<int>>());

    beacon.set(1);
    await BeaconScheduler.settle();
    beacon.set(2);
    await BeaconScheduler.settle();
    beacon.set(3);
    await BeaconScheduler.settle();

    expect(throttled.value, 0);

    await delay(k10ms * 2);

    expect(throttled.value, 0);
  });

  test('should return a FilteredBeacon', () async {
    final beacon = Beacon.writable(0);

    final filtered = beacon.filter(filter: (prev, next) => next.isEven);

    expect(filtered, isA<FilteredBeacon<int>>());

    beacon.set(1);
    await BeaconScheduler.settle();
    beacon.set(2);
    await BeaconScheduler.settle();
    beacon.set(3);
    await BeaconScheduler.settle();

    expect(filtered.value, 2);
  });

  // test('should throw when wrapping a lazy beacon with start=true', () {
  //   final beacon = Beacon.lazyWritable<int>();

  //   expect(
  //     () => beacon.throttle(duration: k10ms),
  //     throwsException,
  //   );

  //   expect(
  //     () => beacon.debounce(duration: k10ms),
  //     throwsException,
  //   );

  //   expect(
  //     beacon.filter,
  //     throwsException,
  //   );
  // });
}
