// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';
import 'chain_test.dart';

void main() {
  test('should reflect original beacon value in wrapper beacon', () {
    final original = Beacon.readable<int>(10);
    final wrapper = Beacon.writable<int>(0);
    wrapper.wrap(original);
    BeaconScheduler.flush();

    expect(wrapper.value, equals(10));
  });

  test('should remove subscription for all wrapped beacons on dispose',
      () async {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10);
    final doubledCount = Beacon.derived<int>(() => count.value * 2);

    final wrapper = Beacon.writable<int>(0);

    wrapper
      ..wrap(count)
      ..wrap(doubledCount);

    BeaconScheduler.flush();

    expect(wrapper.value, equals(20));

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.dispose();

    await delay();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 1);
  });

  test('should remove subscription for all wrapped beacons', () async {
    final count = Beacon.readable<int>(10);
    final doubledCount = Beacon.derived<int>(() => count.value * 2);

    final wrapper = Beacon.bufferedCount<int>(5);

    wrapper
      ..wrap(count, then: wrapper.add)
      ..wrap(doubledCount);

    BeaconScheduler.flush();

    expect(wrapper.value, equals([]));
    expect(wrapper.currentBuffer.value, [10, 20]);

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.clearWrapped();

    await delay();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 1);
  });

  test('should dispose internal currentBuffer on dispose', () async {
    final beacon = Beacon.bufferedCount<int>(5);

    beacon.add(1);
    beacon.add(2);

    BeaconScheduler.flush();

    expect(beacon.currentBuffer.value, [1, 2]);

    beacon.dispose();

    expect(beacon.currentBuffer.peek(), <int>[]);
    expect(beacon.currentBuffer.isDisposed, true);
  });

  test('should apply transformation function', () {
    final original = Beacon.readable<int>(2);
    final wrapper = Beacon.writable<String>('');
    final bufWrapper = Beacon.bufferedCount<String>(10);

    wrapper.wrap(original, then: (val) => wrapper.value = 'Number $val');
    bufWrapper.wrap(original, then: (val) => bufWrapper.add('Number $val'));

    BeaconScheduler.flush();

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

    final numsFast = Beacon.stream(() => stream);
    final numsSlow = Beacon.throttled<AsyncValue<int>>(
      AsyncLoading(),
      duration: const Duration(milliseconds: 200),
    );

    BeaconScheduler.flush();

    const maxCalls = 15;

    numsSlow.wrap(numsFast);
    BeaconScheduler.flush();

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

    numsSlow.subscribe(
      (value) {
        if (throttledCalled < maxCalls) {
          throttledCalled++;
        } else {
          throw Exception('Should not have been called');
        }
      },
      startNow: false,
    );

    await delay(k10ms * 40);

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
    final buff = doubledCount.filter(neverFilter).buffer(1);

    BeaconScheduler.flush();

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
    final sum = Beacon.writable(20);

    final wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);

    sum.wrap(
      wrapper,
      disposeTogether: true,
    );

    BeaconScheduler.flush();

    expect(wrapper.value, equals(10));

    expect(count.listenersCount, 1);

    wrapper.dispose();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 0);
  });

  test('should dispose together when wrapped is disposed(2)', () {
    // BeaconObserver.instance = LoggingObserver();
    final count = Beacon.readable<int>(10, name: 'readable');

    final wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);

    BeaconScheduler.flush();

    expect(wrapper.value, equals(10));

    expect(count.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
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

    beacon.dispose();
  });

  test('should ingest stream and transform values', () async {
    // BeaconObserver.instance = LoggingObserver();
    final beacon = Beacon.writable<int>(0);
    final myStream = Stream.fromIterable([1, 2, 3]);
    final buffered = beacon.buffer(4);

    beacon.ingest(myStream, then: (v) => beacon.value = v * 2);

    await expectLater(
      buffered.next(),
      completion([0, 2, 4, 6]),
    );
  });

  test('should autobatch', () async {
    final original = Beacon.writable(10);
    final wrapper = Beacon.writable(0);

    wrapper.wrap(original);
    expect(wrapper.value, 0);
    await expectLater(wrapper.next(), completion(10));

    original.value = 20;
    original.value = 30;
    original.value = 40;
    original.value = 50;
    expect(wrapper.value, 10); // should not update immediately
    await expectLater(wrapper.next(), completion(50));
  });
}
