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
}
