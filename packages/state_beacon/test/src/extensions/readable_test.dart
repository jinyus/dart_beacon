import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/extensions/extensions.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert to a value listenable', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toListenable();

    expect(valueNotifier, isA<ValueListenable<int>>());

    var called = 0;

    int fn() => called++;
    valueNotifier.addListener(fn);

    beacon.value = 1;

    BeaconScheduler.flush();

    expect(called, 1);

    beacon.value = 2;

    BeaconScheduler.flush();

    expect(called, 2);

    valueNotifier.removeListener(fn);

    beacon.value = 3;

    BeaconScheduler.flush();

    expect(called, 2);
  });

  test('should not notify after source beacon is disposed', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toListenable();

    expect(valueNotifier, isA<ValueListenable<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    BeaconScheduler.flush();

    expect(called, 1);

    beacon.value = 2;

    BeaconScheduler.flush();

    expect(called, 2);

    beacon
      ..dispose()
      ..value = 3;

    BeaconScheduler.flush();

    expect(called, 2);
  });

  test('should return the same listener instance', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toListenable();
    final valueNotifier2 = beacon.toListenable();
    final valueNotifier3 = beacon.toListenable();

    expect(valueNotifier, valueNotifier2);
    expect(valueNotifier2, valueNotifier3);

    expect(hasNotifier(beacon), isTrue);

    beacon.dispose();

    expect(hasNotifier(beacon), isFalse);
  });

  test('should remove notifier from cache when source is disposed.', () {
    final age = Beacon.writable(50);
    final name = Beacon.writable('bob');

    age.toListenable();
    name.toListenable();

    expect(hasNotifier(age), isTrue);
    expect(hasNotifier(name), isTrue);

    age.dispose();

    expect(hasNotifier(age), isFalse);
    expect(hasNotifier(name), isTrue);

    name.dispose();

    expect(hasNotifier(age), isFalse);
    expect(hasNotifier(name), isFalse);
  });
}
