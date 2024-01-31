// ignore_for_file: cascade_invocations, unnecessary_statements

import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../common.dart';

void main() {
  test('should reflect original beacon value in wrapper beacon', () {
    final original = Beacon.readable<int>(10);
    final wrapper = Beacon.writable<int>(0);
    wrapper.wrap(original);

    expect(wrapper.value, equals(10));
  });

  test('should remove subscription for all wrapped beacons on dispose', () {
    final count = Beacon.readable<int>(10);
    final doubledCount = Beacon.derived<int>(() => count.value * 2);

    final wrapper = Beacon.writable<int>(0);

    wrapper.wrap(count);
    wrapper.wrap(doubledCount);

    expect(wrapper.value, equals(20));

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.dispose();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 0);
  });

  test('should remove subscription for all wrapped beacons', () {
    final count = Beacon.readable<int>(10);
    final doubledCount = Beacon.derived<int>(() => count.value * 2);

    final wrapper = Beacon.bufferedCount<int>(5);

    wrapper.wrap(count, then: wrapper.add);
    wrapper.wrap(doubledCount);

    expect(wrapper.value, equals([]));
    expect(wrapper.currentBuffer.value, [10, 20]);

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.clearWrapped();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 0);
  });

  test('should dispose internal currentBuffer on dispose', () {
    final beacon = Beacon.bufferedCount<int>(5);

    beacon.add(1);
    beacon.add(2);

    expect(beacon.currentBuffer.value, [1, 2]);

    beacon.dispose();

    expect(beacon.currentBuffer.value, <int>[]);
    expect(beacon.currentBuffer.isDisposed, true);
  });

  test('should apply transformation function', () {
    final original = Beacon.readable<int>(2);
    final wrapper = Beacon.writable<String>('');
    final bufWrapper = Beacon.bufferedCount<String>(10);

    wrapper.wrap(original, then: (val) => wrapper.value = 'Number $val');
    bufWrapper.wrap(original, then: (val) => bufWrapper.add('Number $val'));

    expect(wrapper.value, equals('Number 2'));
    expect(bufWrapper.currentBuffer.value, equals(['Number 2']));
  });

  test('should throw when no then function is supplied', () {
    final original = Beacon.readable<int>(2);
    final wrapper = Beacon.writable<String>('');
    final bufWrapper = Beacon.bufferedCount<String>(10);

    expect(
      () => wrapper.wrap(original),
      throwsA(isA<WrapTargetWrongTypeException>()),
    );

    try {
      bufWrapper.wrap(original);
    } catch (e) {
      expect(e, isA<WrapTargetWrongTypeException>());
      expect(e.toString(), contains(bufWrapper.name));
    }

    expect(
      () => bufWrapper.wrap(original),
      throwsA(isA<WrapTargetWrongTypeException>()),
    );
  });

  test('should throttle wrapped StreamBeacon', () async {
    final stream = Stream.periodic(const Duration(milliseconds: 20), (i) => i);

    final numsFast = Beacon.stream(stream);
    final numsSlow = Beacon.throttled<AsyncValue<int>>(
      AsyncLoading(),
      duration: const Duration(milliseconds: 200),
    );

    const maxCalls = 15;

    numsSlow.wrap(numsFast);
    var streamCalled = 0;
    var throttledCalled = 0;

    numsFast.subscribe((value) {
      if (streamCalled < maxCalls) {
        if (streamCalled == maxCalls - 1) {
          numsFast.unsubscribe();
        }

        streamCalled++;
      } else {
        throw Exception('Should not have been called');
      }
    });

    numsSlow.subscribe((value) {
      if (throttledCalled < maxCalls) {
        throttledCalled++;
      } else {
        throw Exception('Should not have been called');
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(streamCalled, equals(15));
    expect(throttledCalled, equals(1));
  });

  test('should dispose together when wrapper is disposed', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10, name: 'readable');
    final doubledCount = Beacon.derived<int>(
      () => count.value * 2,
      name: 'derived',
    );

    final wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);
    final buff = doubledCount.buffer(1).filter();

    expect(wrapper.value, equals(10));

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.dispose();

    expect(doubledCount.listenersCount, 1);

    doubledCount.dispose();

    expect(count.listenersCount, 0);
    expect(buff.listenersCount, 0);
  });

  test('should dispose together when wrapped is disposed', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10, name: 'readable');
    final doubledCount = Beacon.derived<int>(
      () => count.value * 2,
      name: 'derived',
    );

    final wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);

    doubledCount.filter().buffer(1).wrap(
          wrapper,
          disposeTogether: true,
        );

    expect(wrapper.value, equals(10));

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.dispose();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 0);
  });

  test('should dispose together when wrapped is disposed(2)', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10, name: 'readable');

    final wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);

    expect(wrapper.value, equals(10));

    expect(count.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
  });

  test('should dispose together when wrapped is disposed(3)', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10);

    final beacon = count
        .buffer(2)
        .filter()
        .throttle(duration: k10ms)
        .debounce(duration: k10ms);

    Beacon.effect(() => beacon.value);

    expect(count.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
    expect(beacon.listenersCount, 0);
  });

  test('should throw when wrapping empty lazy beacon and startNow=true', () {
    final count = Beacon.lazyWritable<int>();

    final wrapper = Beacon.writable<int>(0);

    expect(() => wrapper.wrap(count), throwsException);
  });

  test('should ingest stream', () async {
    final beacon = Beacon.writable<int>(0);
    final myStream = Stream.fromIterable([1, 2, 3]);
    final buffered = beacon.buffer(4);

    beacon
      ..ingest(myStream)
      ..ingest(myStream, then: (v) => v * 2); // should have no effect

    await expectLater(
      buffered.next(),
      completion([0, 1, 2, 3]),
    );
  });

  test('should ingest stream and transform values', () async {
    final beacon = Beacon.writable<int>(0);
    final myStream = Stream.fromIterable([1, 2, 3]);
    final buffered = beacon.buffer(4);

    beacon.ingest(myStream, then: (v) => beacon.value = v * 2);

    await expectLater(
      buffered.next(),
      completion([0, 2, 4, 6]),
    );
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
}
