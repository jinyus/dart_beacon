// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/src/producer.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should dispose together when wrapped is disposed(3)', () async {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10);

    final beacon = count
        .filter()
        .throttle(duration: k10ms)
        .debounce(duration: k10ms)
        .filter();

    Beacon.effect(() => beacon.value);

    await BeaconScheduler.settle();

    expect(count.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
    expect(beacon.listenersCount, 0);
  });

  test('should delegate writes to parent when chained', () async {
    final beacon = Beacon.writable<int>(0);
    final filtered = beacon.filter(filter: (p, n) => n.isEven);

    filtered.value = 1;

    await BeaconScheduler.settle();

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.increment();

    await BeaconScheduler.settle();

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.value = 2;

    await BeaconScheduler.settle();

    expect(beacon.value, 2);
    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/2', () async {
    // BeaconObserver.instance = LoggingObserver();
    final filtered = Beacon.lazyDebounced<int>(duration: k10ms)
        .filter(filter: (p, n) => n.isEven);

    filtered.value = 1; // 1st value so not debounced

    await BeaconScheduler.settle();

    expect(filtered.value, 1);

    filtered.increment();

    await BeaconScheduler.settle();

    expect(filtered.value, 1); // debouncing so not updated yet

    await delay(k10ms * 2);

    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/3', () async {
    // BeaconObserver.instance = LoggingObserver();

    final filtered = Beacon.writable(0)
        .filter(filter: (p, n) => n.isEven, name: 'f1')
        .filter(filter: (p, n) => n > 0, name: 'f2')
        .filter(filter: (p, n) => n > 10, name: 'f3');

    filtered.value = 1;

    await BeaconScheduler.settle();

    expect(filtered.value, 0);

    filtered.value = -2; // doesn't pass f2

    await BeaconScheduler.settle();

    expect(filtered.value, 0);

    filtered.value = 6; // doesn't pass f3

    await BeaconScheduler.settle();

    expect(filtered.value, 0);

    filtered.value = 12;

    await BeaconScheduler.settle();

    expect(filtered.value, 12);

    filtered.value = 0;

    await BeaconScheduler.settle();

    expect(filtered.value, 12);

    filtered.reset();

    await BeaconScheduler.settle();

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

    await BeaconScheduler.settle();

    expect(filtered.value, 10);

    await delay(k10ms * 2.1);

    expect(filtered.value, 10);

    filtered.value = 30;

    await BeaconScheduler.settle();

    expect(filtered.value, 10); // debounced

    await delay(k10ms * 1.1);

    expect(filtered.value, 30);
  });

  test('should delegate writes to parent when chained/5', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final buffered = count
        .filter(name: 'f1', filter: (_, n) => n > 5)
        .buffer(2, name: 'buffered');

    await BeaconScheduler.settle();

    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[10]);

    buffered.add(20);

    await BeaconScheduler.settle();

    expect(count.value, 20);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[]);

    buffered.add(2); // doesn't pass filter

    await BeaconScheduler.settle();

    expect(count.value, 2);
    expect(buffered.value, <int>[10, 20]); // no change
    expect(buffered.currentBuffer(), <int>[]); // no change

    buffered.add(50); // doesn't pass filter

    await BeaconScheduler.settle();

    expect(count.value, 50);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[50]);

    buffered.add(70); // doesn't pass filter

    await BeaconScheduler.settle();

    expect(count.value, 70);
    expect(buffered.value, <int>[50, 70]);
    expect(buffered.currentBuffer(), <int>[]);

    // BeaconObserver.instance = LoggingObserver();

    buffered.reset();

    await BeaconScheduler.settle();

    expect(count.value, 10);
    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[10]);
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

  test('should buffer input beacon', () async {
    final stream = Stream.periodic(k1ms, (i) => i);
    final beacon = stream.toRawBeacon(isLazy: true).buffer(5);

    await BeaconScheduler.settle();

    await expectLater(beacon.next(), completion([0, 1, 2, 3, 4]));
  });

  test('should filter input beacon', () async {
    final stream = Stream.periodic(k1ms, (i) => i);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .filter(filter: (p, n) => n.isEven)
        .buffer(5);

    await BeaconScheduler.settle();

    await expectLater(beacon.next(), completion([0, 2, 4, 6, 8]));
  });

  test('should debounce input beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(9);
    final beacon =
        stream.toRawBeacon(isLazy: true).debounce(duration: k10ms).buffer(5);

    await BeaconScheduler.settle();

    expect(beacon(), <int>[]);
    await expectLater(beacon.currentBuffer.next(), completion([0]));
  });

  test('should throttle input beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(15);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .throttle(duration: k10ms * 1.3)
        .buffer(2);

    await BeaconScheduler.settle();

    final result = await beacon.next();

    // it will have 1 val less than 10 and 1 val more than 10
    expect(result.reduce((a, b) => a + b), inInclusiveRange(10, 20));
    expect(beacon.currentBuffer(), isEmpty);
  });

  test('should throttle input beacon and keep blocked values', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(15);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .throttle(duration: k10ms, dropBlocked: false)
        .buffer(2);

    await BeaconScheduler.settle();

    final result = await beacon.next();

    expect(result, [0, 1]);
  });

  test('should force all delegated writes', () async {
    final count = Beacon.writable<int>(10);
    var called = 0;

    final buff = count
        .filter(name: 'f1', filter: (p, n) => n > 5)
        .buffer(2, name: 'buffered');

    await BeaconScheduler.settle();

    count.subscribe((p0) => called++);

    expect(called, isSynchronousMode ? 1 : 0);

    buff.add(20);

    await BeaconScheduler.settle();

    expect(called, isSynchronousMode ? 2 : 1);

    expect(buff(), [10, 20]);
    expect(buff.currentBuffer(), isEmpty);

    buff.add(20);

    await BeaconScheduler.settle();

    expect(called, isSynchronousMode ? 3 : 2);

    expect(buff.currentBuffer(), [20]);

    buff.add(5);

    await BeaconScheduler.settle();

    expect(called, isSynchronousMode ? 4 : 3);

    expect(buff.currentBuffer(), [20]);

    buff.add(5);

    await BeaconScheduler.settle();

    expect(called, isSynchronousMode ? 5 : 4);

    expect(buff.currentBuffer(), [20]);
  });

  test('should force all delegated writes (throttled)', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final tbeacon = count.throttle(duration: k10ms, name: 'throttled');

    final buff = count.buffer(5, name: 'buff');

    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (debounced)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.debounce(duration: k10ms);

    final buff = count.buffer(5);

    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (filtered)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.filter(filter: (p, n) => n > 5);

    final buff = count.buffer(5);

    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(20);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();
    tbeacon.set(5);
    await BeaconScheduler.settle();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (buffered)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.buffer(5);

    final buff = count.buffer(5);

    tbeacon.add(20);
    await BeaconScheduler.settle();
    tbeacon.add(20);
    await BeaconScheduler.settle();
    tbeacon.add(5);
    await BeaconScheduler.settle();
    tbeacon.add(5);
    await BeaconScheduler.settle();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (bufferedTime)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.bufferTime(duration: k10ms);

    final buff = count.buffer(5);

    tbeacon.add(20);
    await BeaconScheduler.settle();
    tbeacon.add(20);
    await BeaconScheduler.settle();
    tbeacon.add(5);
    await BeaconScheduler.settle();
    tbeacon.add(5);
    await BeaconScheduler.settle(k10ms * 1.1);

    expect(buff.value, [10, 20, 20, 5, 5]);
  });
}
