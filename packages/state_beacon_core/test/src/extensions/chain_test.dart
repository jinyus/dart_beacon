import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should dispose together when wrapped is disposed(3)', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10);

    final beacon = count
        .filter()
        .throttle(duration: k10ms)
        .debounce(duration: k10ms)
        .filter();

    Beacon.effect(() => beacon.value);

    expect(count.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
    expect(beacon.listenersCount, 0);
  });
  test('should delegate writes to parent when chained', () {
    final beacon = Beacon.writable<int>(0);
    final filtered = beacon.filter(filter: (p, n) => n.isEven);

    filtered.value = 1;

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.increment();

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.value = 2;

    expect(beacon.value, 2);
    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/2', () async {
    // BeaconObserver.instance = LoggingObserver();
    final filtered = Beacon.lazyDebounced<int>(duration: k10ms)
        .filter(filter: (p, n) => n.isEven);

    filtered.value = 1;

    await Future<void>.delayed(k10ms * 1.1);

    expect(filtered.value, 1);

    filtered.increment();

    expect(filtered.value, 1); // debouncing so not updated yet

    await Future<void>.delayed(k10ms * 1.1);

    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/3', () {
    // BeaconObserver.instance = LoggingObserver();

    final filtered = Beacon.writable(0)
        .filter(filter: (p, n) => n.isEven, name: 'f1')
        .filter(filter: (p, n) => n > 0, name: 'f2')
        .filter(filter: (p, n) => n > 10, name: 'f3');

    filtered.value = 1;

    expect(filtered.value, 0);

    filtered.value = -2; // doesn't pass f2

    expect(filtered.value, 0);

    filtered.value = 6; // doesn't pass f3

    expect(filtered.value, 0);

    filtered.value = 12;

    expect(filtered.value, 12);

    filtered.value = 0;

    expect(filtered.value, 12);

    filtered.reset();

    expect(filtered.value, 0);
  });

  test('should delegate writes to parent when chained/4', () async {
    // BeaconObserver.instance = LoggingObserver();

    final count = Beacon.writable<int>(10, name: 'count');

    final filtered = count
        .throttle(duration: k10ms, name: 'throttled')
        .debounce(duration: k10ms, name: 'debounced')
        .filter(name: 'f1')
        .filter(name: 'f2');

    expect(filtered.isEmpty, false);
    expect(filtered.value, 10);

    filtered.value = 20; // throttled

    expect(filtered.value, 10);

    await Future<void>.delayed(k10ms * 2.1);

    expect(filtered.value, 10);

    filtered.value = 30;

    expect(filtered.value, 10); // debounced

    await Future<void>.delayed(k10ms * 1.1);

    expect(filtered.value, 30);
  });

  test('should delegate writes to parent when chained/5', () {
    // BeaconObserver.instance = LoggingObserver();

    final count = Beacon.writable<int>(10, name: 'count');

    final buffered = count
        .filter(name: 'f1', filter: (_, n) => n > 5)
        .buffer(2, name: 'buffered');

    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[10]);

    buffered.add(20);

    expect(count.value, 20);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[]);

    buffered.add(2); // doesn't pass filter

    expect(count.value, 2);
    expect(buffered.value, <int>[10, 20]); // no change
    expect(buffered.currentBuffer(), <int>[]); // no change

    buffered.add(50); // doesn't pass filter

    expect(count.value, 50);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[50]);

    buffered.add(70); // doesn't pass filter

    expect(count.value, 70);
    expect(buffered.value, <int>[50, 70]);
    expect(buffered.currentBuffer(), <int>[]);

    buffered.reset();

    expect(count.value, 10);
    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[]);
  });

  test('should throw when trying to chain a buffered beacon', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final buffered = Beacon.bufferedCount<int>(5);
    final buffTime = Beacon.bufferedTime<int>(duration: k10ms);

    expect(
      buffered.filter,
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffTime.buffer(10),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.debounce(duration: k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.throttle(duration: k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.bufferTime(duration: k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => count
          .filter(name: 'f1', filter: (_, n) => n > 5)
          .buffer(2, name: 'buffered')
          .debounce(duration: k10ms),
      throwsA(isA<AssertionError>()),
    );
  });
}
