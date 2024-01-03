import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should create a new beacon', () {
    var family = Beacon.family((int arg) => Beacon.writable(arg.toString()));
    var beacon = family(1);

    expect(beacon.value, '1');
  });

  test('should create a new future beacon', () async {
    var counter = Beacon.writable(10);

    var counterMirror = Beacon.derivedFuture(() async {
      var count = counter.value;
      await Future.delayed(k10ms);
      return count;
    });

    var family = Beacon.family((int arg) => Beacon.derivedFuture(() async {
          var count = await counterMirror.toFuture();
          await Future.delayed(k10ms);
          return (count * arg).toString();
        }));

    var doubled = family(2);

    expect(doubled.value, AsyncLoading());

    await Future.delayed(k10ms * 2.1);

    expect(doubled.value.unwrapValue(), '20');

    var tripled = family(3);

    expect(tripled.value, AsyncLoading());

    await Future.delayed(k10ms * 2.1);

    expect(tripled.value.unwrapValue(), '30');

    counter.increment();

    expect(doubled.value, AsyncLoading());
    expect(tripled.value, AsyncLoading());

    await Future.delayed(k10ms * 4);

    expect(doubled.value.unwrapValue(), '22');
    expect(tripled.value.unwrapValue(), '33');
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

    family.clear();
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
