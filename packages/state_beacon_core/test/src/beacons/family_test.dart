// ignore_for_file: inference_failure_on_function_invocation, cascade_invocations, lines_longer_than_80_chars

import 'package:state_beacon_core/src/creator/creator.dart';
import 'package:state_beacon_core/src/extensions/extensions.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should create a new beacon', () {
    final family = Beacon.family((int arg) => Beacon.writable(arg.toString()));
    final beacon = family(1);

    expect(beacon.value, '1');
  });

  test('should create a new future beacon', () async {
    final counter = Beacon.writable(10);

    final counterMirror = Beacon.future(() async {
      final count = counter.value;
      return count;
    });

    final family = Beacon.family(
      (int arg) => Beacon.future(() async {
        final count = await counterMirror.toFuture();
        await delay(k1ms);
        return (count * arg).toString();
      }),
    );

    final doubled = family(2);

    expect(doubled.isLoading, true);

    await delay();

    expect(doubled.value.unwrap(), '20');

    final tripled = family(3);

    expect(tripled.isLoading, true);

    await delay();

    expect(tripled.value.unwrap(), '30');

    counter.increment();

    await delay();

    expect(doubled.value.unwrap(), '22');
    expect(tripled.value.unwrap(), '33');
  });

  // Test for caching behavior
  test('should cache created beacons', () {
    final family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: true,
    );
    final beacon1 = family(1);
    final beacon2 = family(1);

    // Both beacons should be the same instance
    expect(identical(beacon1, beacon2), isTrue);
  });

  test('should remove from cache when disposed', () {
    final family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: true,
    );
    final beacon1 = family(1);

    beacon1.dispose();

    final beacon2 = family(1);

    expect(identical(beacon1, beacon2), isFalse);
  });

  test('should not cache Beacons if cache is false', () {
    final family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: false,
    );
    final beacon1 = family(1);
    final beacon2 = family(1);

    // Beacons should not be the same instance
    expect(identical(beacon1, beacon2), isFalse);

    family.clear();
  });

  test('should clear the cache', () {
    final family = Beacon.family(
      (int arg) => Beacon.writable(arg.toString()),
      cache: true,
    );

    final beacon1 = family(1);

    family.clear();
    final beacon2 = family(1);

    // Beacons should not be the same instance after cache is cleared
    expect(identical(beacon1, beacon2), isFalse);
  });
}
