// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

// ignore: type_annotate_public_apis
bool neverFilter(p, n) => true;
void main() {
  test('should return a BufferedCountBeacon', () async {
    final beacon = Beacon.writable(0);

    final buffered = beacon.buffer(3);

    BeaconScheduler.flush();

    expect(buffered, isA<BufferedCountBeacon<int>>());

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();

    expect(buffered.value, [0, 1, 2]);
  });

  test('should work properly when wrapping a lazy beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final beacon = Beacon.lazyWritable<int>();

    final buffered = beacon.buffer(3);
    final bufferedTime = beacon.bufferTime(k10ms);
    final debounced = beacon.debounce(k10ms);
    final throttled = beacon.throttle(k10ms);
    final filtered = beacon.filter(
      (p0, p1) => p1.isEven,
    );

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();
    beacon.set(4);
    BeaconScheduler.flush();
    beacon.set(5);
    BeaconScheduler.flush();

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

    final buffered = beacon.bufferTime(k10ms);

    BeaconScheduler.flush();

    expect(buffered, isA<BufferedTimeBeacon<int>>());

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();

    expect(buffered.currentBuffer.value, [0, 1, 2, 3]);
    expect(buffered.value, isEmpty);

    await delay(k10ms * 2);
    expect(buffered.value, [0, 1, 2, 3]);
    expect(buffered.currentBuffer.value, isEmpty);
  });

  test('should return a DebouncedBeacon', () async {
    final beacon = Beacon.writable(0);

    final debounced = beacon.debounce(k10ms);

    BeaconScheduler.flush();

    expect(debounced, isA<DebouncedBeacon<int>>());

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();

    expect(debounced.value, 0);

    await delay(k10ms * 2);

    expect(debounced.value, 3);
  });

  test('should return a ThrottledBeacon', () async {
    final beacon = Beacon.writable(0);

    final throttled = beacon.throttle(k10ms);

    BeaconScheduler.flush();

    expect(throttled, isA<ThrottledBeacon<int>>());

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();

    expect(throttled.value, 0);

    await delay(k10ms * 2);

    expect(throttled.value, 0);
  });

  test('should return a FilteredBeacon', () async {
    final beacon = Beacon.writable(0);

    final filtered = beacon.filter((prev, next) => next.isEven);

    expect(filtered, isA<FilteredBeacon<int>>());

    beacon.set(1);
    BeaconScheduler.flush();
    beacon.set(2);
    BeaconScheduler.flush();
    beacon.set(3);
    BeaconScheduler.flush();

    expect(filtered.value, 2);
  });

  test('should dispose together when wrapped is disposed(3)', () async {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10);

    final beacon = count
        .filter(neverFilter)
        .throttle(k10ms)
        .debounce(k10ms)
        .filter(neverFilter);

    BeaconScheduler.flush();

    Beacon.effect(() => beacon.value);

    BeaconScheduler.flush();

    expect(count.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
    expect(beacon.listenersCount, 0);
  });

  test('should throw when trying to chain a buffered beacon', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final buffered = Beacon.bufferedCount<int>(5);
    final buffTime = Beacon.bufferedTime<int>(duration: k10ms);

    BeaconScheduler.flush();

    expect(
      () => buffered.filter(neverFilter),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffTime.buffer(10),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.debounce(k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.throttle(k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => buffered.bufferTime(k1ms),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => count
          .filter(name: 'f1', (_, n) => n > 5)
          .buffer(2, name: 'buffered')
          .debounce(k10ms),
      throwsA(isA<AssertionError>()),
    );
  });

  test('should buffer input beacon', () async {
    final stream = Stream.periodic(k1ms, (i) => i);
    final beacon = stream.toRawBeacon(isLazy: true).buffer(5);

    BeaconScheduler.flush();

    await expectLater(beacon.next(), completion([0, 1, 2, 3, 4]));
  });

  test('should filter input beacon', () async {
    final stream = Stream.periodic(k1ms, (i) => i);
    final beacon =
        stream.toRawBeacon(isLazy: true).filter((p, n) => n.isEven).buffer(5);

    BeaconScheduler.flush();

    await expectLater(beacon.next(), completion([0, 2, 4, 6, 8]));
  });

  test('should debounce input beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(9);
    final beacon = stream.toRawBeacon(isLazy: true).debounce(k10ms).buffer(5);

    BeaconScheduler.flush();

    expect(beacon(), <int>[]);
    await expectLater(beacon.currentBuffer.next(), completion([0]));
  });

  test('should throttle input beacon', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(15);
    final beacon =
        stream.toRawBeacon(isLazy: true).throttle(k10ms * 1.3).buffer(2);

    BeaconScheduler.flush();

    final result = await beacon.next();

    // it will have 1 val less than 10 and 1 val more than 10
    expect(result.reduce((a, b) => a + b), inInclusiveRange(8, 20));
    expect(beacon.currentBuffer(), isEmpty);
  });

  test('should throttle input beacon and keep blocked values', () async {
    // BeaconObserver.instance = LoggingObserver();
    final stream = Stream.periodic(k1ms, (i) => i).take(15);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .throttle(k10ms, dropBlocked: false)
        .buffer(2);

    BeaconScheduler.flush();

    final result = await beacon.next();

    expect(result, [0, 1]);
  });

  test('should transform input values', () async {
    final stream = Stream.periodic(k1ms, (i) => i).take(5);
    final beacon = stream.toRawBeacon(isLazy: true).map((v) => v * 10);

    await expectLater(beacon.stream, emitsInOrder([0, 10, 20, 30, 40]));
  });

  test('should transform input values when use mid-chain', () async {
    final stream = Stream.periodic(k1ms, (i) => i).take(5);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .map((v) => v + 1)
        .filter((_, n) => n.isEven);

    BeaconScheduler.flush();

    await expectLater(beacon.stream, emitsInOrder([1, 2, 4]));
  });

  test('should transform input values when use mid-chain/2', () async {
    final beacon = Beacon.periodic(k10ms, (i) => i)
        .filter((_, n) => n.isEven)
        .map((v) => '$v')
        .throttle(k1ms);

    await expectLater(beacon.stream, emitsInOrder(['0', '2', '4']));
  });

  test('should work when next is paired with buffer', () async {
    // BeaconObserver.useLogging();
    Stream<int> getStream(int limit) async* {
      for (var i = 0; i < limit; i++) {
        yield i;
        await delay(k1ms);
      }
    }

    final s = Beacon.streamRaw(() => getStream(3), isLazy: true);

    await expectLater(s.buffer(3).next(), completion([0, 1, 2]));
  });

  test('should have value if wrapping derived', () async {
    // BeaconObserver.useLogging();
    final count = Beacon.writable<int>(0);

    final derived = Beacon.derived(() => count.value * 2);

    final throttled = derived.throttle(k10ms);

    BeaconScheduler.flush();

    expect(throttled.value, 0);
  });
}
