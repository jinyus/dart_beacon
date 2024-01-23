import 'package:test/test.dart';
import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

import '../common.dart';

void main() {
  test('should reflect original beacon value in wrapper beacon', () {
    var original = Beacon.readable<int>(10);
    var wrapper = Beacon.writable<int>(0);
    wrapper.wrap(original);

    expect(wrapper.value, equals(10));
  });

  test('should remove subscription for all wrapped beacons on dispose', () {
    var count = Beacon.readable<int>(10);
    var doubledCount = Beacon.derived<int>(() => count.value * 2);

    var wrapper = Beacon.writable<int>(0);

    wrapper.wrap(count);
    wrapper.wrap(doubledCount);

    expect(wrapper.value, equals(20));

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.clearWrapped();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 1);
  });

  test('should remove subscription for all wrapped beacons', () {
    var count = Beacon.readable<int>(10);
    var doubledCount = Beacon.derived<int>(() => count.value * 2);

    var wrapper = Beacon.bufferedCount<int>(5);

    wrapper.wrap(count, then: (c) => wrapper.add(c));
    wrapper.wrap(doubledCount);

    expect(wrapper.value, equals([]));
    expect(wrapper.currentBuffer.value, [10, 20]);

    expect(doubledCount.listenersCount, 1);
    expect(count.listenersCount, 2);

    wrapper.clearWrapped();

    expect(doubledCount.listenersCount, 0);
    expect(count.listenersCount, 1);
  });

  test('should dispose internal currentBuffer on dispose', () {
    var beacon = Beacon.bufferedCount<int>(5);

    beacon.add(1);
    beacon.add(2);

    expect(beacon.currentBuffer.value, [1, 2]);

    beacon.dispose();

    expect(beacon.currentBuffer.value, <int>[]);
    expect(beacon.currentBuffer.isDisposed, true);
  });

  test('should apply transformation function', () {
    var original = Beacon.readable<int>(2);
    var wrapper = Beacon.writable<String>("");
    var bufWrapper = Beacon.bufferedCount<String>(10);

    wrapper.wrap(original, then: (val) => wrapper.value = 'Number $val');
    bufWrapper.wrap(original, then: (val) => bufWrapper.add('Number $val'));

    expect(wrapper.value, equals('Number 2'));
    expect(bufWrapper.currentBuffer.value, equals(['Number 2']));
  });

  test('should throw when no then function is supplied', () {
    var original = Beacon.readable<int>(2);
    var wrapper = Beacon.writable<String>("");
    var bufWrapper = Beacon.bufferedCount<String>(10);

    expect(() => wrapper.wrap(original),
        throwsA(isA<WrapTargetWrongTypeException>()));

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
    final stream = Stream.periodic(Duration(milliseconds: 20), (i) => i);

    final numsFast = Beacon.stream(stream);
    final numsSlow = Beacon.throttled<AsyncValue<int>>(
      AsyncLoading(),
      duration: Duration(milliseconds: 200),
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

    await Future<void>.delayed(Duration(milliseconds: 400));

    expect(streamCalled, equals(15));
    expect(throttledCalled, equals(1));
  });

  test('should dispose together when wrapper is disposed', () {
    // BeaconObserver.instance = LoggingObserver();
    var count = Beacon.readable<int>(10, name: 'readable');
    var doubledCount = Beacon.derived<int>(
      () => count.value * 2,
      name: 'derived',
    );

    var wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);
    var buff = doubledCount.buffer(1).filter();

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
    var count = Beacon.readable<int>(10, name: 'readable');
    var doubledCount = Beacon.derived<int>(
      () => count.value * 2,
      name: 'derived',
    );

    var wrapper = Beacon.writable<int>(0, name: 'wrapper');

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
    var count = Beacon.readable<int>(10, name: 'readable');

    var wrapper = Beacon.writable<int>(0, name: 'wrapper');

    wrapper.wrap(count, disposeTogether: true);

    expect(wrapper.value, equals(10));

    expect(count.listenersCount, 1);

    count.dispose();

    expect(count.listenersCount, 0);
  });

  test('should dispose together when wrapped is disposed(3)', () {
    // BeaconObserver.instance = LoggingObserver();
    var count = Beacon.readable<int>(10);

    var beacon = count
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
    var count = Beacon.lazyWritable<int>();

    var wrapper = Beacon.writable<int>(0);

    expect(() => wrapper.wrap(count), throwsException);
  });
}
