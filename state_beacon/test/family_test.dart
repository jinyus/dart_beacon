import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should create a new beacon', () {
    var family = Beacon.family((int arg) => Beacon.writable(arg.toString()));
    var beacon = family(1);

    expect(beacon.value, '1');
  });

  // Test for caching behavior
  test('should cache created beacons', () {
    var family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: true,
    );
    var beacon1 = family(1);
    var beacon2 = family(1);

    // Both beacons should be the same instance
    expect(identical(beacon1, beacon2), isTrue);
  });

  test('should not cache Beacons if cache is false', () {
    var family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: false,
    );
    var beacon1 = family(1);
    var beacon2 = family(1);

    // Beacons should not be the same instance
    expect(identical(beacon1, beacon2), isFalse);
  });

  test('should clear the cache', () {
    var family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: true,
    );

    var beacon1 = family(1);

    family.clear();
    var beacon2 = family(1);

    // Beacons should not be the same instance after cache is cleared
    expect(identical(beacon1, beacon2), isFalse);
  });
}
