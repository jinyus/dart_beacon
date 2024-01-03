import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

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

    wrapper.wrap(count, then: (b, c) => b.add(c));
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

    expect(beacon.currentBuffer.value, []);
    expect(beacon.currentBuffer.isDisposed, true);
  });

  test('should apply transformation function', () {
    var original = Beacon.readable<int>(2);
    var wrapper = Beacon.writable<String>("");
    var bufWrapper = Beacon.bufferedCount<String>(10);

    wrapper.wrap(original, then: (w, val) => w.value = 'Number $val');
    bufWrapper.wrap(original, then: (w, val) => w.add('Number $val'));

    expect(wrapper.value, equals('Number 2'));
    expect(bufWrapper.currentBuffer.value, equals(['Number 2']));
  });

  test('should throw when no then function is supplied', () {
    var original = Beacon.readable<int>(2);
    var wrapper = Beacon.writable<String>("");
    var bufWrapper = Beacon.bufferedCount<String>(10);

    expect(() => wrapper.wrap(original),
        throwsA(isA<WrapTargetWrongTypeException>()));
    expect(
      () => bufWrapper.wrap(original),
      throwsA(isA<WrapTargetWrongTypeException>()),
    );
  });

  test('should throw when derived is started twice', () {
    var count = Beacon.readable<int>(2);
    var asText = Beacon.derived<String>(() => count.value.toString());

    expect(
      () => asText.start(),
      throwsA(isA<DerivedBeaconStartedTwiceException>()),
    );
  });

  test('should dispose internal status when disposed', () {
    var count = Beacon.readable<int>(2);
    var asText = Beacon.derived<String>(() => count.value.toString());

    expect(asText.value, count.value.toString());

    asText.dispose();

    expect(asText.isDisposed, true);
    expect(asText.status.isDisposed, true);
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

    await Future.delayed(Duration(milliseconds: 400));

    expect(streamCalled, equals(15));
    expect(throttledCalled, equals(1));
  });
}
