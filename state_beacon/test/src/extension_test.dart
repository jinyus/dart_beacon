import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should create relevant beacons', () {
    var listBeacon = [].toBeacon();

    expect(listBeacon, isA<ListBeacon>());

    listBeacon.add(1);

    expect(listBeacon.value, equals([1]));

    var streamBeacon = Stream.value(1).toBeacon();

    expect(streamBeacon, isA<StreamBeacon>());

    expect(streamBeacon.value, isA<AsyncLoading>());

    var rawStreamBeacon = Stream.value(1).toRawBeacon(initialValue: 1);

    expect(rawStreamBeacon, isA<RawStreamBeacon>());

    expect(rawStreamBeacon.value, 1);
  });

  test('should convert a beacon to a stream', () async {
    var beacon = Beacon.writable(0);
    var stream = beacon.toStream();

    expect(stream, isA<Stream<int>>());

    expect(
        stream,
        emitsInOrder([
          0,
          1,
          2,
          emitsDone,
        ]));

    beacon.value = 1;
    beacon.value = 2;
    beacon.dispose();
  });

  test('should toggle bool beacon', () {
    var beacon = Beacon.writable(false);

    beacon.toggle();

    expect(beacon.value, true);

    beacon.toggle();

    expect(beacon.value, false);
  });

  test('should increment/decrement num beacon', () {
    var beacon = Beacon.writable(0);

    beacon.increment();

    expect(beacon.value, 1);

    beacon.increment();

    expect(beacon.value, 2);

    beacon.decrement();

    expect(beacon.value, 1);

    beacon.decrement();

    expect(beacon.value, 0);
  });

  test('should convert to a value notifier', () {
    var beacon = Beacon.writable(0);

    var valueNotifier = beacon.toValueNotifier();

    expect(valueNotifier, isA<ValueNotifier<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    expect(called, 1);

    beacon.value = 2;

    expect(called, 2);

    valueNotifier.dispose();

    beacon.value = 3;

    expect(called, 2);
  });
}
