import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
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
        BeaconScheduler.flush();
        beacon.set(42);
      }, // Even, should be completed with this value
    );

    final result = await futureValue;

    expect(result, 42);
  });

  test('next method unsubscribes after value is setted', () async {
    final beacon = Beacon.writable(0);

    final futureValue = beacon.next();

    expect(beacon.listenersCount, 1);

    beacon.set(42);

    BeaconScheduler.flush();

    await futureValue; // Ensure the future is completed

    expect(beacon.listenersCount, 0);

    // set more values, and the future should not complete again
    beacon.set(99);

    BeaconScheduler.flush();

    // Assert that the future didn't complete again
    expect(futureValue, completes);

    // should be the same value as before
    await expectLater(await futureValue, 42);
  });

  test(
    'next should complete with current value if beacon is disposed',
    () {
      final beacon = Beacon.writable(0);

      final futureValue = beacon.next();

      beacon.dispose();

      expect(futureValue, completion(0));
    },
  );

  test(
    'next should complete with fallback value if beacon is disposed',
    () {
      final beacon = Beacon.lazyWritable<int>();

      final futureValue = beacon.next(fallback: 10);

      beacon.dispose();

      expect(futureValue, completion(10));
    },
  );

  test(
    'next should complete with current value if fallback '
    'is provided but beacon is not lazy disposed',
    () {
      final beacon = Beacon.writable<int>(50);

      final futureValue = beacon.next(fallback: 10);

      beacon.dispose();

      expect(futureValue, completion(50));
    },
  );

  test(
    'next should complete with error if '
    'lazy beacon is disposed and no fallback is provided',
    () {
      final beacon = Beacon.lazyWritable<int>();

      final futureValue = beacon.next();

      beacon.dispose();

      expect(futureValue, throwsException);
    },
  );

  test('next method completes with the setted value/derived', () async {
    final beacon = Beacon.writable(0);

    final d = Beacon.derived(() => beacon.value * 2);

    Timer(k10ms, () => beacon.set(42));

    final result = await d.next();

    expect(result, 84);
  });

  test('next method with filter only completes with matching values/derived',
      () async {
    final beacon = Beacon.writable(0);

    final d = Beacon.derived(() => beacon.value);

    final futureValue = d.next(filter: (value) => value.isEven);

    Timer(
      k10ms,
      () async {
        beacon.set(3); // Not even, should be ignored
        BeaconScheduler.flush();
        beacon.set(42);
      }, // Even, should be completed with this value
    );

    final result = await futureValue;

    expect(result, 42);
  });

  test('next method unsubscribes after value is setted/derived', () async {
    final beacon = Beacon.writable(0, name: 'beacon');

    final d = Beacon.derived(() => beacon.value, name: 'd');

    final futureValue = d.next();

    await delay();

    expect(d.listenersCount, 1);

    beacon.set(42);

    BeaconScheduler.flush();

    await futureValue; // Ensure the future is completed

    expect(d.listenersCount, 0);

    // set more values, and the future should not complete again
    beacon.set(99);

    BeaconScheduler.flush();

    // Assert that the future didn't complete again
    expect(futureValue, completes);

    // should be the same value as before
    await expectLater(await futureValue, 42);
  });

  test(
    'next should complete with current value if beacon is disposed/derived',
    () async {
      final beacon = Beacon.writable(0);

      final d = Beacon.derived(() => beacon.value);

      final futureValue = d.next();

      await delay(); // allow derived to run

      d.dispose();

      expect(futureValue, completion(0));
    },
  );

  test(
    'next should complete with fallback value if beacon is disposed/derived',
    () {
      final beacon = Beacon.writable(0);

      final d = Beacon.derived(() => beacon.value);

      final futureValue = d.next(fallback: 10);

      d.dispose(); // dispose the derived before it's initialized

      expect(futureValue, completion(10));
    },
  );

  test(
    'next should complete with current value if fallback '
    'is provided but lazy beacon gets a value',
    () async {
      final beacon = Beacon.writable<int>(50);

      final d = Beacon.derived(() => beacon.value);

      final futureValue = d.next(fallback: 10);

      await delay();

      d.dispose();

      expect(futureValue, completion(50));
    },
  );

  test(
    'next should complete with error if '
    'lazy beacon is disposed and no fallback is provided',
    () {
      final beacon = Beacon.writable(0);

      final d = Beacon.derived(() => beacon.value);

      final futureValue = d.next();

      d.dispose();

      expect(futureValue, throwsException);
    },
  );
}
