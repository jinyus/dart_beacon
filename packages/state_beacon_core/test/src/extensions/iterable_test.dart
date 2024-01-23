import 'package:test/test.dart';
import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

void main() {
  test('should create relevant beacons', () {
    var listBeacon = <int>[].toBeacon();

    expect(listBeacon, isA<ListBeacon<int>>());

    listBeacon.add(1);

    expect(listBeacon.value, equals([1]));

    var streamBeacon = Stream.value(1).toBeacon();

    expect(streamBeacon, isA<StreamBeacon<int>>());

    expect(streamBeacon.value, isA<AsyncLoading<int>>());

    var rawStreamBeacon = Stream.value(1).toRawBeacon(initialValue: 1);

    expect(rawStreamBeacon, isA<RawStreamBeacon<int>>());

    expect(rawStreamBeacon.value, 1);
  });
}
