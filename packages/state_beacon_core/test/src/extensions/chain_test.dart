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
    final bufferedTime = beacon.bufferTime(duration: k10ms);
    final debounced = beacon.debounce(duration: k10ms);
    final throttled = beacon.throttle(duration: k10ms);
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

    final buffered = beacon.bufferTime(duration: k10ms);

    expect(buffered, isA<BufferedTimeBeacon<int>>());

    buffered.add(1);
    BeaconScheduler.flush();
    buffered.add(2);
    BeaconScheduler.flush();
    buffered.add(3);
    BeaconScheduler.flush();

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

    final throttled = beacon.throttle(duration: k10ms);

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
        .throttle(duration: k10ms)
        .debounce(duration: k10ms)
        .filter(neverFilter);

    Beacon.effect(() => beacon.value);

    BeaconScheduler.flush();

    expect(count.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
    expect(beacon.listenersCount, 0);
  });

  test('should delegate writes to parent when chained', () async {
    final beacon = Beacon.writable<int>(0);
    final filtered = beacon.filter((p, n) => n.isEven);

    filtered.value = 1;

    BeaconScheduler.flush();

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.increment();

    BeaconScheduler.flush();

    expect(beacon.value, 1);
    expect(filtered.value, 0);

    filtered.value = 2;

    BeaconScheduler.flush();

    expect(beacon.value, 2);
    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/2', () async {
    // BeaconObserver.instance = LoggingObserver();
    final filtered =
        Beacon.lazyDebounced<int>(duration: k10ms).filter((p, n) => n.isEven);

    filtered.value = 1; // 1st value so not debounced

    BeaconScheduler.flush();

    expect(filtered.value, 1);

    filtered.increment();

    BeaconScheduler.flush();

    expect(filtered.value, 1); // debouncing so not updated yet

    await delay(k10ms * 2);

    expect(filtered.value, 2);
  });

  test('should delegate writes to parent when chained/3', () async {
    // BeaconObserver.instance = LoggingObserver();

    final filtered = Beacon.writable(0)
        .filter((p, n) => n.isEven, name: 'f1')
        .filter((p, n) => n > 0, name: 'f2')
        .filter((p, n) => n > 10, name: 'f3');

    filtered.value = 1;

    BeaconScheduler.flush();

    expect(filtered.value, 0);

    filtered.value = -2; // doesn't pass f2

    BeaconScheduler.flush();

    expect(filtered.value, 0);

    filtered.value = 6; // doesn't pass f3

    BeaconScheduler.flush();

    expect(filtered.value, 0);

    filtered.value = 12;

    BeaconScheduler.flush();

    expect(filtered.value, 12);

    filtered.value = 0;

    BeaconScheduler.flush();

    expect(filtered.value, 12);

    filtered.reset();

    BeaconScheduler.flush();

    expect(filtered.value, 0);
  });

  test('should delegate writes to parent when chained/4', () async {
    // BeaconObserver.instance = LoggingObserver();

    final count = Beacon.writable<int>(10, name: 'count');

    final filtered = count
        .throttle(duration: k10ms, name: 'throttled')
        .debounce(duration: k10ms, name: 'debounced')
        .filter(neverFilter, name: 'f1')
        .filter(neverFilter, name: 'f2');

    expect(filtered.isEmpty, false);
    expect(filtered.value, 10);

    filtered.value = 20; // throttled

    BeaconScheduler.flush();

    expect(filtered.value, 10);

    await delay(k10ms * 2.1);

    expect(filtered.value, 10);

    filtered.value = 30;

    BeaconScheduler.flush();

    expect(filtered.value, 10); // debounced

    await delay(k10ms * 1.1);

    expect(filtered.value, 30);
  });

  test('should delegate writes to parent when chained/5', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final buffered =
        count.filter(name: 'f1', (_, n) => n > 5).buffer(2, name: 'buffered');

    BeaconScheduler.flush();

    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[10]);

    buffered.add(20);

    BeaconScheduler.flush();

    expect(count.value, 20);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[]);

    buffered.add(2); // doesn't pass filter

    BeaconScheduler.flush();

    expect(count.value, 2);
    expect(buffered.value, <int>[10, 20]); // no change
    expect(buffered.currentBuffer(), <int>[]); // no change

    buffered.add(50); // doesn't pass filter

    BeaconScheduler.flush();

    expect(count.value, 50);
    expect(buffered.value, <int>[10, 20]);
    expect(buffered.currentBuffer(), <int>[50]);

    buffered.add(70); // doesn't pass filter

    BeaconScheduler.flush();

    expect(count.value, 70);
    expect(buffered.value, <int>[50, 70]);
    expect(buffered.currentBuffer(), <int>[]);

    // BeaconObserver.instance = LoggingObserver();

    buffered.reset();

    BeaconScheduler.flush();

    expect(count.value, 10);
    expect(buffered.value, <int>[]);
    expect(buffered.currentBuffer(), <int>[10]);
  });

  test('should throw when trying to chain a buffered beacon', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final buffered = Beacon.bufferedCount<int>(5);
    final buffTime = Beacon.bufferedTime<int>(duration: k10ms);

    expect(
      () => buffered.filter(neverFilter),
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
          .filter(name: 'f1', (_, n) => n > 5)
          .buffer(2, name: 'buffered')
          .debounce(duration: k10ms),
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
    final beacon =
        stream.toRawBeacon(isLazy: true).debounce(duration: k10ms).buffer(5);

    BeaconScheduler.flush();

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
        .throttle(duration: k10ms, dropBlocked: false)
        .buffer(2);

    BeaconScheduler.flush();

    final result = await beacon.next();

    expect(result, [0, 1]);
  });

  test('should force all delegated writes', () async {
    final count = Beacon.writable<int>(10);
    var called = 0;

    final buff =
        count.filter(name: 'f1', (p, n) => n > 5).buffer(2, name: 'buffered');

    BeaconScheduler.flush();

    count.subscribe((p0) => called++);

    expect(called, 0);

    buff.add(20);

    BeaconScheduler.flush();

    expect(called, 1);

    expect(buff(), [10, 20]);
    expect(buff.currentBuffer(), isEmpty);

    buff.add(20);

    BeaconScheduler.flush();

    expect(called, 2);

    expect(buff.currentBuffer(), [20]);

    buff.add(5);

    BeaconScheduler.flush();

    expect(called, 3);

    expect(buff.currentBuffer(), [20]);

    buff.add(5);

    BeaconScheduler.flush();

    expect(called, 4);

    expect(buff.currentBuffer(), [20]);
  });

  test('should force all delegated writes (throttled)', () async {
    final count = Beacon.writable<int>(10, name: 'count');

    final tbeacon = count.throttle(duration: k10ms, name: 'throttled');

    final buff = count.buffer(5, name: 'buff');

    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (debounced)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.debounce(duration: k10ms);

    final buff = count.buffer(5);

    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (filtered)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.filter((p, n) => n > 5);

    final buff = count.buffer(5);

    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(20);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();
    tbeacon.set(5);
    BeaconScheduler.flush();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (buffered)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.buffer(5);

    final buff = count.buffer(5);

    tbeacon.add(20);
    BeaconScheduler.flush();
    tbeacon.add(20);
    BeaconScheduler.flush();
    tbeacon.add(5);
    BeaconScheduler.flush();
    tbeacon.add(5);
    BeaconScheduler.flush();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should force all delegated writes (bufferedTime)', () async {
    final count = Beacon.writable<int>(10);

    final tbeacon = count.bufferTime(duration: k10ms);

    final buff = count.buffer(5);

    tbeacon.add(20);
    BeaconScheduler.flush();
    tbeacon.add(20);
    BeaconScheduler.flush();
    tbeacon.add(5);
    BeaconScheduler.flush();
    tbeacon.add(5);
    BeaconScheduler.flush();

    expect(buff.value, [10, 20, 20, 5, 5]);
  });

  test('should transform input values', () async {
    final stream = Stream.periodic(k1ms, (i) => i).take(5);
    final beacon = stream.toRawBeacon(isLazy: true).map((v) => v * 10);

    await expectLater(beacon.toStream(), emitsInOrder([0, 10, 20, 30, 40]));
  });

  test('should transform input values when use mid-chain', () async {
    final stream = Stream.periodic(k1ms, (i) => i).take(5);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .map((v) => v + 1)
        .filter((_, n) => n.isEven);

    await expectLater(beacon.toStream(), emitsInOrder([1, 2, 4]));
  });

  test('should transform input values when use mid-chain/2', () async {
    final stream = Stream.periodic(k1ms, (i) => i).take(5);
    final beacon = stream
        .toRawBeacon(isLazy: true)
        .filter((_, n) => n.isEven)
        .map((v) => v + 1)
        .throttle(duration: k1ms);

    await expectLater(beacon.toStream(), emitsInOrder([1, 3, 5]));

    await delay();

    // rerouted to filtered beacon first
    beacon.set(10);
    expect(beacon.value, 11);
  });

  test('should not delegate to map beacon when output type differs', () {
    final count = Beacon.writable<int>(10);

    final mapped = count.map((v) => '${v * 2}');

    expect(mapped.value, '20');

    count.value = 20;

    expect(mapped.value, '40');

    final buff = mapped.buffer(5);

    buff.add('60');
    BeaconScheduler.flush();
    expect(buff.currentBuffer(), ['40', '60']);
    // can't delegate to map because the input type is different
    expect(count.value, 20);
    expect(mapped.value, '40');

    count.value = 30;
    expect(mapped.value, '60');
    expect(buff.currentBuffer(), ['40', '60', '60']);

    count.value = 40;
    expect(mapped.value, '80');
    expect(buff.currentBuffer(), ['40', '60', '60', '80']);

    count.value = 50;
    expect(mapped.value, '100');
    expect(buff(), ['40', '60', '60', '80', '100']);
    expect(buff.currentBuffer(), <String>[]);

    buff.reset();
    expect(buff.value, <String>[]);
    expect(buff.currentBuffer(), <String>[]);
    // these won't change because the input type is different
    expect(count.value, 50);
    expect(mapped.value, '100');
  });

  test('should delegate to map beacon when output type is the same', () {
    final count = Beacon.writable<int>(10);

    final mapped = count.map((v) => v * 2);

    expect(mapped.value, 20);

    count.value = 20;

    expect(mapped.value, 40);

    final buff = mapped.buffer(5);

    buff.add(60);
    BeaconScheduler.flush();
    expect(buff.currentBuffer(), [40, 120]);
    expect(count.value, 60);
    expect(mapped.value, 120);

    count.value = 30;
    expect(mapped.value, 60);
    expect(buff.currentBuffer(), [40, 120, 60]);

    buff.add(40);
    expect(mapped.value, 80);
    expect(buff.currentBuffer(), [40, 120, 60, 80]);

    buff.add(50);
    expect(mapped.value, 100);
    expect(buff(), [40, 120, 60, 80, 100]);

    buff.reset();
    expect(buff.value, <int>[]);
    expect(buff.currentBuffer(), <int>[20]);
    expect(count.value, 10);
    expect(mapped.value, 20);
  });

  test(
    "should delegate to map when it's the first writable in the chain",
    () async {
      final stream = Stream.periodic(k1ms, (i) => i).take(5);
      final beacon = stream
          .toRawBeacon(isLazy: true)
          .map((v) => v + 1)
          .filter((_, n) => n.isEven);

      await expectLater(beacon.toStream(), emitsInOrder([1, 2, 4]));

      beacon.set(10);

      // map added 1 making it 11, filter removed it
      expect(beacon.value, 4);

      beacon.set(11);
      expect(beacon.value, 12);

      beacon.reset();
      expect(beacon.value, 1);
    },
  );

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
}
