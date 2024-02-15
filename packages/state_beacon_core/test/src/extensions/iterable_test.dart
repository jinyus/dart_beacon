import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should create relevant beacons', () {
    final listBeacon = <int>[].toBeacon();

    expect(listBeacon, isA<ListBeacon<int>>());

    listBeacon.add(1);

    expect(listBeacon.value, equals([1]));

    final streamBeacon = Stream.value(1).toBeacon();

    expect(streamBeacon, isA<StreamBeacon<int>>());

    expect(streamBeacon.value, isA<AsyncLoading<int>>());

    final rawStreamBeacon = Stream.value(1).toRawBeacon(initialValue: 1);

    expect(rawStreamBeacon, isA<RawStreamBeacon<int>>());

    expect(rawStreamBeacon.value, 1);
  });
}
